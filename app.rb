require 'sinatra'
require 'sinatra/json'
require 'sidekiq'
require 'sidekiq-status'

require File.expand_path '../workers/ping_worker.rb', __FILE__

configure do
  Sidekiq.configure_client do |config|
    config.redis = { url: ENV["REDISTOGO_URL"] || "redis://localhost:6379/" }

    config.client_middleware do |chain|
      chain.add Sidekiq::Status::ClientMiddleware
    end
  end

  Sidekiq.configure_server do |config|
    config.redis = { url: ENV["REDISTOGO_URL"] || "redis://localhost:6379/" }

    config.server_middleware do |chain|
      chain.add Sidekiq::Status::ServerMiddleware, expiration: 30*60 # default
    end
    config.client_middleware do |chain|
      chain.add Sidekiq::Status::ClientMiddleware
    end
  end

  require "./lib/adapters/adapter"
  Dir["./lib/adapters/*/*.rb"].each do |file|
    require file
  end
end

get '/' do
  "hello world"
end

post '/petitions/:agency' do |agency|
  job_id = PingWorker.perform_async({
    user: params[:message],
    petition: params[:petition]})
  job_status = Sidekiq::Status::status(job_id)
  json job: job_id, status: job_status
end

get '/agencies' do
  json Bazooka::Adapter.registered.map {|id, adapter|
    [id, adapter.full_name]
  }.to_h
end

get '/agencies/:agency' do |agency|
  json Bazooka::Adapter.registered[agency].dependencies
end

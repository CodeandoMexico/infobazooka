require 'sinatra'
require 'sinatra/json'
require 'sidekiq'
require 'sidekiq-status'
require 'mongo'
require 'json/ext'

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

  mongo_url = ENV['MONGOLAB_URI'] || 'mongodb://127.0.0.1:27017/bazooka'
  client = Mongo::Client.new(mongo_url)
  set :mongo_db, client[:petitions]

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

get '/petitions/:job_id' do |job_id|
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

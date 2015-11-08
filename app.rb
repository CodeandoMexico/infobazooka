require 'sinatra'
require 'sinatra/json'
require 'sidekiq'
require 'sidekiq-status'

require File.expand_path '../workers/ping_worker.rb', __FILE__

configure do
  Sidekiq.configure_client do |config|
    config.client_middleware do |chain|
      chain.add Sidekiq::Status::ClientMiddleware
    end
  end

  Sidekiq.configure_server do |config|
    config.server_middleware do |chain|
      chain.add Sidekiq::Status::ServerMiddleware, expiration: 30.minutes # default
    end
    config.client_middleware do |chain|
      chain.add Sidekiq::Status::ClientMiddleware
    end
  end
end

configure do

  Dir["./lib/**/*.rb"].each do |file|
    require file
  end

end

get '/' do
  "hello world"
end

post '/petitions' do
  job_id = PingWorker.perform_async(params[:message])
  job_status = Sidekiq::Status::status(job_id)
  json job: job_id, status: job_status
end

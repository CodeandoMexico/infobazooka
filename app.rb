require 'sinatra'
require 'sinatra/json'
require File.expand_path '../workers/ping_worker.rb', __FILE__

get '/' do
  "hello world"
end

post '/petitions' do
  json({
    job: PingWorker.perform_async(params[:message]),
    status: "pending"
  })
end

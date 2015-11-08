require 'sinatra'
require File.expand_path '../workers/ping_worker.rb', __FILE__

get '/' do
  "hello world"
end

post '/petitions' do
  PingWorker.perform_async params[:message]
end

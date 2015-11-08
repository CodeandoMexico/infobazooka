require 'rack/test'
require 'rspec'
require 'sidekiq/testing'
require 'mechanize'
Sidekiq::Testing.fake!

require File.expand_path '../../app.rb', __FILE__
require File.expand_path '../../workers/ping_worker.rb', __FILE__

ENV['RACK_ENV'] = 'test'

module RSpecMixin
  include Rack::Test::Methods
  def app() Sinatra::Application end
end

# For RSpec 2.x
RSpec.configure { |c| c.include RSpecMixin }

require 'sidekiq'

class PingWorker
  include Sidekiq::Worker
  def perform(message)
    puts message
  end
end

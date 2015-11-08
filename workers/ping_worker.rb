class PingWorker
  include Sidekiq::Worker
  def perform(message)
    adapter = Bazooka::Adapter.fetch('gobierno-federal')
    adapter.auth(username: ENV['USER'],  password: ENV['PASS'])
    adapter.publish(message)
  end
end

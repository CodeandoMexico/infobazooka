class PingWorker
  include Sidekiq::Worker
  def perform(message)
    adapter = Bazooka::Adapter.fetch('gobierno-federal')
    adapter.auth(username: ENV['test_user'],  password: ENV['test_password'])
    adapter.publish(message)
  end
end

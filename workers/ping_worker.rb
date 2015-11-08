class PingWorker
  include Sidekiq::Worker
  def perform(message)
    adapter = Bazooka::Adapter.fetch('gobierno-federal')
    adapter.auth(username: ENV['USER'],  password: ENV['PASS'])
    folio = adapter.publish(message)
  end
end

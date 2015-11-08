require File.expand_path '../spec_helper.rb', __FILE__

describe "Ping worker" do
  it "should say pong after a while" do
    expect {
      post '/petitions', message: "ping"
    }.to change(PingWorker.jobs, :size).by(1)
  end
end

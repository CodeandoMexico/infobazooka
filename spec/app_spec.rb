require File.expand_path '../spec_helper.rb', __FILE__

describe "My info-bazooka" do
  it "should say hello" do
    get '/'
    expect(last_response.body).to eq("hello world")
  end

  it "should return job id for petition worker" do
    post '/petitions', message: "ping"
    job_id = PingWorker.jobs.last['jid']
    response = { :job => job_id, :status => "pending" }
    expect(last_response.body).to eq(response.to_json)
  end
end

require File.expand_path '../spec_helper.rb', __FILE__

describe "My info-bazooka" do
  it "should say hello" do
    get '/'
    expect(last_response.body).to eq("hello world")
  end

  it "should return job id for petition worker" do
    post '/petitions', message: "ping"
    job_id = PingWorker.jobs.last['jid']
    job_status = Sidekiq::Status::status(job_id)
    response = { :job => job_id, :status => job_status }
    expect(last_response.body).to eq(response.to_json)
  end
end

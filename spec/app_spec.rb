require File.expand_path '../spec_helper.rb', __FILE__

describe "My info-bazooka" do
  it "should say hello" do
    get '/'
    expect(last_response.body).to eq("hello world")
  end

  it "should return job id for petition worker" do
    post '/petitions/gobierno-federal', message: "ping"
    job_id = PingWorker.jobs.last['jid']
    job_status = Sidekiq::Status::status(job_id)
    response = { :job => job_id, :status => job_status }
    expect(last_response.body).to eq(response.to_json)
  end

  it "should return status for a job" do
    job_id = PingWorker.jobs.last['jid']
    get "/petitions/#{job_id}"
    job_status = Sidekiq::Status::status(job_id)
    response = { :job => job_id, :status => job_status }
    expect(last_response.body).to eq(response.to_json)
  end

  it "should store jobs in mongo" do
    bacon_string = 'I want bacon'
    expect {
      post '/petitions/gobierno-federal', {
        petition: { text: bacon_string }
      }
    }.to change(app.mongo_db.find, :count).by(1)

    last_petition = app.mongo_db.find.to_a.last
    expect(last_petition['text']).to eq(bacon_string)

  end
end

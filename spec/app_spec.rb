require File.expand_path '../spec_helper.rb', __FILE__

describe "My info-bazooka" do
  it "should say hello" do
    get '/'
    expect(last_response.body).to eq("hello world")
  end
end

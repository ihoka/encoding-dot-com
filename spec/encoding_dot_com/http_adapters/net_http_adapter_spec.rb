require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "NetHttpAdapter" do
  before :each do
    @http = EncodingDotCom::HttpAdapters::NetHttpAdapter.new
    
  end

  it "should respond to post with a url and hash of post parameters" do
    Net::HTTP.should_receive(:post_form).with(URI.parse("http://example.com"), {:foo => "bar"})
    @http.post("http://example.com", {:foo => "bar"})
  end

  it "should raise an AvailabilityError if an exception is raised" do
    Net::HTTP.should_receive(:post_form).and_raise(Net::HTTPBadResponse.new("bad!"))
    lambda { @http.post("http://example.com") }.should raise_error(EncodingDotCom::AvailabilityError, "bad!")
  end

  it "should raise an AvailabilityError if a timeout error is raised" do
    Net::HTTP.should_receive(:post_form).and_raise(Timeout::Error.new("bad!"))
    lambda { @http.post("http://example.com") }.should raise_error(EncodingDotCom::AvailabilityError, "bad!")
  end

  it "should return a response with a status code" do
    response = stub(:code => "200", :body => "Hello!")
    Net::HTTP.should_receive(:post_form).and_return(response)

    @http.post("http://example.com").code.should == "200"
  end

  it "should return a response with a body" do
    response = stub(:code => "200", :body => "Hello!")
    Net::HTTP.should_receive(:post_form).and_return(response)

    @http.post("http://example.com").body.should == "Hello!"
  end
end

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "CurbAdapter" do
  before :each do
    @http = EncodingDotCom::HttpAdapters::CurbAdapter.new
    @mock_easy = mock("Curl::Easy mock", :null_object => true)
    @mock_easy.should_receive(:follow_location=).with(true)    
    Curl::Easy.should_receive(:new).with("http://example.com").and_yield(@mock_easy).and_return(@mock_easy)    
  end

  it "should respond to post with a url and hash of post parameters" do
    @mock_easy.should_receive(:http_post)
    Curl::PostField.should_receive(:content).with("foo", "bar")
    
    @http.post("http://example.com", {:foo => "bar"})
  end

  it "should raise an AvailabilityError if a Curl exception is raised" do
    @mock_easy.should_receive(:http_post).and_raise(StandardError.new("Boom!"))

    lambda { @http.post("http://example.com") }.should raise_error(EncodingDotCom::AvailabilityError, "Boom!")
  end

  it "should return a response with a status code" do
    @mock_easy.should_receive(:http_post)
    @mock_easy.should_receive(:response_code).and_return(200)
    @http.post("http://example.com").code.should == "200"
  end

  it "should return a response with a body" do
    @mock_easy.should_receive(:http_post)
    @mock_easy.should_receive(:body_str).and_return("Hello!")
    @http.post("http://example.com").body.should == "Hello!"
  end
end

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "CurbAdapter" do
  before :each do
    @http = EncodingDotCom::HttpAdapters::CurbAdapter.new
    @mock_easy = mock("Curl::Easy mock")
    @mock_easy.should_receive(:follow_location=).with(true)    
  end

  it "should respond to post with a url and hash of post parameters" do
    @mock_easy.should_receive(:http_post)
    Curl::Easy.should_receive(:new).with("http://example.com").and_yield(@mock_easy).and_return(@mock_easy)
    Curl::PostField.should_receive(:content).with("foo", "bar")
    
    @http.post("http://example.com", {:foo => "bar"})
  end

  it "should raise an AvailabilityError if a Curl exception is raised" do
    @mock_easy.should_receive(:http_post).and_raise(EncodingDotCom::AvailabilityError.new("Boom!"))
    Curl::Easy.should_receive(:new).with("http://example.com").and_yield(@mock_easy).and_return(@mock_easy)
    
    lambda { @http.post("http://example.com") }.should raise_error(EncodingDotCom::AvailabilityError)
  end
end

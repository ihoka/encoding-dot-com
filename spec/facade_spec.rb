require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Encoding.com Facade" do

  before :each do
    @http = mock("Http Interface")
    @facade = EncodingDotCom::Facade.new(1234, "abcd", @http)
  end

  def expect_xml_with_xpath(xpath)
    @http.should_receive(:post).with(EncodingDotCom::Facade::ENDPOINT,
                                     EncodingXpathMatcher.new(xpath)).and_return(stub("Http Response", :code => 200))
  end
  
  describe " any xml sent to encoding.com" do
    it "should have a root query node" do
      expect_xml_with_xpath("/query")
      @facade.process(stub("source"), stub("destination"), stub("format"))
    end

    it "should have a user_id node" do
      expect_xml_with_xpath("/query/userid[text()=1234]")
      @facade.process(stub("source"), stub("destination"), stub("format"))
    end

    it "should have a user key node" do
      expect_xml_with_xpath("/query/userkey[text()='abcd']")
      @facade.process(stub("source"), stub("destination"), stub("format"))
    end
  end

  describe "request sent to encoding.com" do
    it "should return true if a success" do
      @http.should_receive(:post).and_return(stub("Http Response", :code => 200))
      @facade.process(stub("source"), stub("destination"), stub("format")).should be_true
    end

    it "should raise an AvailabilityError if response status from encoding.com is not a 200" do
      @http.should_receive(:post).and_return(stub("Http Response", :code => 503))
      lambda { @facade.process(stub("source"), stub("destination"), stub("format")) }.should raise_error(EncodingDotCom::AvailabilityError)
    end

    it "should raise an MessageError if response contains errors" do
      response = stub("Http Response",
                      :code => 200,
                      :to_s => "<?xml version=\"1.0\"?>\n<response><errors><error>Wrong query format</error></errors></response>\n")
      @http.should_receive(:post).and_return(response)
      lambda { @facade.process(stub("source"), stub("destination"), stub("format")) }.should raise_error(EncodingDotCom::MessageError)
    end
  end
  
  describe "xml sent to encoding.com to process a video" do
    it "should have an action of 'AddMedia'." do
      expect_xml_with_xpath("/query/action[text()='AddMedia']")
      @facade.process(stub("source"), stub("destination"), stub("format"))
    end

    it "should include the source url" do
      expect_xml_with_xpath("/query/source[text()='http://example.com/']")
      @facade.process("http://example.com/", stub("destination"), stub("format"))
    end
  end
end

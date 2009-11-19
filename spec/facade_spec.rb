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

  def expect_response_xml(response_xml)
    response = stub("Http Response", :code => 200, :to_s => response_xml)
    @http.should_receive(:post).and_return(response)
  end
  
  describe " any xml sent to encoding.com" do
    [:add_and_process, :status].each do |method|
      it "should have a root query node for method #{method}" do
        expect_xml_with_xpath("/query")
        @facade.send(method, stub("source"))
      end

      it "should have a user_id node for method #{method}" do
        expect_xml_with_xpath("/query/userid[text()=1234]")
        @facade.send(method, stub("source"))        
      end

      it "should have a user key node for method #{method}" do
        expect_xml_with_xpath("/query/userkey[text()='abcd']")
        @facade.send(method, stub("source"))                
      end
    end
  end

  describe "request sent to encoding.com" do
    it "should return true if a success" do
      @http.should_receive(:post).and_return(stub("Http Response", :code => 200))
      @facade.add_and_process(stub("source"), {}).should be_true
    end

    it "should raise an AvailabilityError if response status from encoding.com is not a 200" do
      @http.should_receive(:post).and_return(stub("Http Response", :code => 503))
      lambda { @facade.add_and_process(stub("source"), {}) }.should raise_error(EncodingDotCom::AvailabilityError)
    end

    it "should raise an MessageError if response contains errors" do
      response = stub("Http Response",
                      :code => 200,
                      :to_s => "<?xml version=\"1.0\"?>\n<response><errors><error>Wrong query format</error></errors></response>\n")
      @http.should_receive(:post).and_return(response)
      lambda { @facade.add_and_process(stub("source"), {}) }.should raise_error(EncodingDotCom::MessageError)
    end
  end
  
  describe "xml sent to encoding.com to process a video" do
    it "should have an action of 'AddMedia'." do
      expect_xml_with_xpath("/query/action[text()='AddMedia']")
      @facade.add_and_process(stub("source"), {})
    end

    it "should include the source url" do
      expect_xml_with_xpath("/query/source[text()='http://example.com/']")
      @facade.add_and_process("http://example.com/", {})
    end

    it "should include the formats provided" do
      expect_xml_with_xpath("/query/format/output[text()='flv']")
      format = EncodingDotCom::Format.new("output" => "flv")
      @facade.add_and_process(stub("source"), {stub("destination") => format})
    end

    it "should include the destination urls in the formats provided" do
      expect_xml_with_xpath("/query/format/destination[text()='http://example.com']")
      format = EncodingDotCom::Format.new("output" => "flv")
      @facade.add_and_process(stub("source"), {"http://example.com" => format})
    end
  end

  describe "calling add_and_process" do
    it "should return the a media id" do
      expect_response_xml("<response><MediaID>1234</MediaID></response>")
      @facade.add_and_process(stub("source"), {}).should == 1234
    end
  end

  describe "xml sent to encoding.com to get the status of a job" do
    it "should include a action node with 'GetStatus'" do
      expect_xml_with_xpath("/query/action[text()='GetStatus']")
      @facade.status("mediaid")
    end

    it "should include a media id node" do
      expect_xml_with_xpath("/query/mediaid[text()='abcd']")
      @facade.status("abcd")
    end

    describe "simple status method" do
      it "should respond with a string status from encoding.com" do
        expect_response_xml("<response><status>New</status></response>")
        @facade.status("mediaid").should == "New"
      end
    end
  end
end

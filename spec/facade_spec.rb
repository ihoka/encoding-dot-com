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
  
  describe "any xml sent to encoding.com" do
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
      format = EncodingDotCom::Format.create("output" => "flv")
      @facade.add_and_process(stub("source"), {stub("destination") => format})
    end

    it "should include the destination urls in the formats provided" do
      expect_xml_with_xpath("/query/format/destination[text()='http://example.com']")
      format = EncodingDotCom::Format.create("output" => "flv")
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
  end

  describe "calling simple status method" do
    it "should respond with a string status from encoding.com" do
      expect_response_xml("<response><status>New</status></response>")
      @facade.status("mediaid").should == "New"
    end
  end

  describe "calling get media list method" do
    it "should include an action node with 'GetMediaList'" do
      expect_xml_with_xpath("/query/action[text()='GetMediaList']")
      @facade.list
    end
    
    describe "returned MediaListItems" do
      before :each do
        expect_response_xml(<<-END
        <response>
            <media>
                <mediafile>foo.wmv</mediafile>
                <mediaid>1234</mediaid>
                <mediastatus>Closed</mediastatus>
                <createdate>2009-01-01 12:00:01</createdate>
                <startdate>2009-01-01 12:00:02</startdate>
                <finishdate>2009-01-01 12:00:03</finishdate>
            </media>
        </response>
        END
        )
      end
      
      it "should return an array of media list values" do
        @facade.list.should be_kind_of(Enumerable)
      end

      it "should have a hash of returned attributes with a mediafile key" do
        @facade.list.first.media_file.should == "foo.wmv"
      end
      
      it "should have a hash of returned attributes with a mediaid key" do
        @facade.list.first.media_id.should == 1234
      end
      
      it "should have a hash of returned attributes with a mediastatus key" do
        @facade.list.first.media_status.should == "Closed"
      end
      
      it "should have a hash of returned attributes with a createdate key" do
        @facade.list.first.create_date.should == Time.local(2009, 1, 1, 12, 0, 1)
      end

      it "should have a hash of returned attributes with a startdate key" do
        @facade.list.first.start_date.should == Time.local(2009, 1, 1, 12, 0, 2)
      end

      it "should have a hash of returned attributes with a finishdate key" do
        @facade.list.first.finish_date.should == Time.local(2009, 1, 1, 12, 0, 3)
      end
    end
  end

  describe "deleting specified media and all its items in the queue" do
    it "should have an action of 'CancelMedia'." do
      expect_xml_with_xpath("/query/action[text()='CancelMedia']")
      @facade.cancel(5678)
    end

    it "should have a mediaid of 1234." do
      expect_xml_with_xpath("/query/mediaid[text()='5678']")
      @facade.cancel(5678)
    end
  end

  describe "getting information about a specified media item" do
    it "should have an action of 'GetMediaInfo'." do
      expect_xml_with_xpath("/query/action[text()='GetMediaInfo']")
      @facade.info(5678)
    end

    it "should have a mediaid of 1234." do
      expect_xml_with_xpath("/query/mediaid[text()='5678']")
      @facade.cancel(5678)
    end
  end
end

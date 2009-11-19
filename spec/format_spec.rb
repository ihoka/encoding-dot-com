require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Encoding.com Format" do

  describe "output" do
    it "should have a output attribute" do
      EncodingDotCom::Format.new("output" => "flv").output.should == "flv"
    end

    it "should be required" do
      lambda { EncodingDotCom::Format.new }.should raise_error(EncodingDotCom::IllegalFormatAttribute)
    end

    it "should not allow an illegal format" do
      lambda { EncodingDotCom::Format.new("output" => "foo") }.should raise_error(EncodingDotCom::IllegalFormatAttribute)
    end

    it "should allow flv, fl9, wmv, 3gp, mp4, m4v, ipod, iphone, appletv, psp, zune, mp3, wma and thumbnail output formats" do
      %w{flv fl9 wmv 3gp mp4 m4v ipod iphone appletv psp zune vp6 mp3 wma thumbnail}.each do |format|
        lambda { EncodingDotCom::Format.new("output" => format) }.should_not raise_error
      end
    end
  end

  describe "specifying the size of the output video" do
    it "should have a size attribute" do
      EncodingDotCom::Format.new("output" => "flv", "size" => "640x480").size.should == "640x480"
    end

    it "should be nil if neither width nor height are specified" do
      EncodingDotCom::Format.new("output" => "flv").size.should be_nil
    end

    describe "size restrictions" do
      it "should have a sizes of 320x120 or 320x180 if the output format is zune" do
        lambda { EncodingDotCom::Format.new("output" => "zune", "size" => "400x400") }.should raise_error(EncodingDotCom::IllegalFormatAttribute)
        lambda { EncodingDotCom::Format.new("output" => "zune", "size" => "320x120") }.should_not raise_error        
        lambda { EncodingDotCom::Format.new("output" => "zune", "size" => "320x180") }.should_not raise_error
      end
      
      it "should have sizes 320x240 or 640x480 if the output format is ipod" do
        lambda { EncodingDotCom::Format.new("output" => "ipod", "size" => "400x400") }.should raise_error(EncodingDotCom::IllegalFormatAttribute)
      end

      it "should have widths and heights in multiples of 16 if the output format is vp6" do
        lambda { EncodingDotCom::Format.new("output" => "vp6", "size" => "32x32") }.should_not raise_error
        lambda { EncodingDotCom::Format.new("output" => "vp6", "size" => "33x33") }.should raise_error(EncodingDotCom::IllegalFormatAttribute)
      end
    end
  end

  describe "#build_xml" do
    it "should create a format node" do
      format = EncodingDotCom::Format.new("output" => "flv")
      Nokogiri::XML::Builder.new do |b|
        format.build_xml(b)
      end.to_xml.should have_xpath("/format")
    end

    it "should create an output node" do
      format = EncodingDotCom::Format.new("output" => "flv")
      Nokogiri::XML::Builder.new do |b|
        format.build_xml(b)
      end.to_xml.should have_xpath("/format/output[text()='flv']")
    end

    it "should not create a size node if size is not specified" do
      format = EncodingDotCom::Format.new("output" => "flv")
      Nokogiri::XML::Builder.new do |b|
        format.build_xml(b)
      end.to_xml.should_not have_xpath("/format/size")
    end

    it "should create a size node" do
      format = EncodingDotCom::Format.new("output" => "flv", "size" => "0x480")
      Nokogiri::XML::Builder.new do |b|
        format.build_xml(b)
      end.to_xml.should have_xpath("/format/size[text()='0x480']")
    end

    it "should create a logo node for logo attributes" do
      format = EncodingDotCom::Format.new("output" => "flv", "logo_x" => 30)
      Nokogiri::XML::Builder.new do |b|
        format.build_xml(b)
      end.to_xml.should have_xpath("/format/logo/logo_x[text()='30']")
    end

    it "should have a destination node with the url passed to build xml" do
      format = EncodingDotCom::Format.new("output" => "flv")
      Nokogiri::XML::Builder.new do |b|
        format.build_xml(b, "http://example.com")
      end.to_xml.should have_xpath("/format/destination[text()='http://example.com']")
    end
  end
end

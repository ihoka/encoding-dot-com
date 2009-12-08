require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Encoding.com video format" do

  describe "#create" do
    it "should return a VideoFormat when the output type is a video output" do
      EncodingDotCom::Format.create("output" => "mp4").should be_instance_of(EncodingDotCom::VideoFormat)
    end

    it "should return a FLVVP6Format if the output is flv and the video codec is vp6" do
      EncodingDotCom::Format.create("output" => "flv", "video_codec" => "vp6").should be_instance_of(EncodingDotCom::FLVVP6Format)
    end

    it "should return a ImageFormat when the output type is image" do
      EncodingDotCom::Format.create("output" => "image").should be_instance_of(EncodingDotCom::ImageFormat)
    end
  end
  
  describe "#output" do
    it "should have a output attribute" do
      EncodingDotCom::VideoFormat.new("output" => "flv").output.should == "flv"
    end

    it "should be required" do
      lambda { EncodingDotCom::VideoFormat.new }.should raise_error(EncodingDotCom::IllegalFormatAttribute)
    end

    it "should not allow an illegal format" do
      lambda { EncodingDotCom::VideoFormat.new("output" => "foo") }.should raise_error(EncodingDotCom::IllegalFormatAttribute)
    end

    %w{flv fl9 wmv 3gp mp4 m4v ipod iphone appletv psp zune mp3 wma}.each do |format|
      it "should allow #{format} as an output format" do
        lambda { EncodingDotCom::VideoFormat.new("output" => format) }.should_not raise_error
      end
    end
  end

  describe "specifying the size of the output video" do
    it "should have a size attribute" do
      EncodingDotCom::VideoFormat.new("output" => "flv", "size" => "640x480").size.should == "640x480"
    end

    it "should be nil if neither width nor height are specified" do
      EncodingDotCom::VideoFormat.new("output" => "flv").size.should be_nil
    end

    describe "size restrictions" do
      it "should have a sizes of 320x120 or 320x180 if the output format is zune" do
        lambda { EncodingDotCom::VideoFormat.new("output" => "zune", "size" => "400x400") }.should raise_error(EncodingDotCom::IllegalFormatAttribute)
        lambda { EncodingDotCom::VideoFormat.new("output" => "zune", "size" => "320x120") }.should_not raise_error        
        lambda { EncodingDotCom::VideoFormat.new("output" => "zune", "size" => "320x180") }.should_not raise_error
      end
      
      it "should have sizes 320x240 or 640x480 if the output format is ipod" do
        lambda { EncodingDotCom::VideoFormat.new("output" => "ipod", "size" => "400x400") }.should raise_error(EncodingDotCom::IllegalFormatAttribute)
      end
    end
  end

  describe "allowed video codecs for output formats" do
    %w{flv libx264 vp6}.each do |codec|
      it "can be #{codec} if the output format is FLV" do
        lambda { EncodingDotCom::VideoFormat.new("output" => "flv", "video_codec" => codec) }.should_not raise_error
      end
    end

    it "cannot be any other codec if output if Flv" do
      lambda { EncodingDotCom::VideoFormat.new("output" => "flv", "video_codec" => "foo") }.should raise_error(EncodingDotCom::IllegalFormatAttribute)
    end

    %w{mpeg4 libx264}.each do |codec|
      it "can be #{codec} if the output format is MP4" do
        lambda { EncodingDotCom::VideoFormat.new("output" => "mp4", "video_codec" => codec) }.should_not raise_error
      end
    end

    it "cannot be any other codec if output if MP4" do
      lambda { EncodingDotCom::VideoFormat.new("output" => "mp4", "video_codec" => "foo") }.should raise_error(EncodingDotCom::IllegalFormatAttribute)
    end
  end
  
  describe "#build_xml" do
    it "should create a format node" do
      format = EncodingDotCom::VideoFormat.new("output" => "flv")
      Nokogiri::XML::Builder.new do |b|
        format.build_xml(b)
      end.to_xml.should have_xpath("/format")
    end

    it "should create an output node" do
      format = EncodingDotCom::VideoFormat.new("output" => "flv")
      Nokogiri::XML::Builder.new do |b|
        format.build_xml(b)
      end.to_xml.should have_xpath("/format/output[text()='flv']")
    end

    it "should not create a size node if size is not specified" do
      format = EncodingDotCom::VideoFormat.new("output" => "flv")
      Nokogiri::XML::Builder.new do |b|
        format.build_xml(b)
      end.to_xml.should_not have_xpath("/format/size")
    end

    it "should create a size node" do
      format = EncodingDotCom::VideoFormat.new("output" => "flv", "size" => "0x480")
      Nokogiri::XML::Builder.new do |b|
        format.build_xml(b)
      end.to_xml.should have_xpath("/format/size[text()='0x480']")
    end

    it "should create a logo node for logo attributes" do
      format = EncodingDotCom::VideoFormat.new("output" => "flv", "logo_x" => 30)
      Nokogiri::XML::Builder.new do |b|
        format.build_xml(b)
      end.to_xml.should have_xpath("/format/logo/logo_x[text()='30']")
    end

    it "should have a destination node with the url passed to build xml" do
      format = EncodingDotCom::VideoFormat.new("output" => "flv")
      Nokogiri::XML::Builder.new do |b|
        format.build_xml(b, "http://example.com")
      end.to_xml.should have_xpath("/format/destination[text()='http://example.com']")
    end

    %w{two_pass cbr deinterlacing add_meta turbo}.each do |bool|
      it "should output boolean attribute #{bool} as yes when true" do
        format = EncodingDotCom::VideoFormat.new("output" => "flv", bool => true)
        Nokogiri::XML::Builder.new do |b|
          format.build_xml(b, "http://example.com")
        end.to_xml.should have_xpath("/format/#{bool}[text()='yes']")
      end

      it "should output boolean attribute #{bool} as no when false" do
        format = EncodingDotCom::VideoFormat.new("output" => "flv", bool => false)
        Nokogiri::XML::Builder.new do |b|
          format.build_xml(b, "http://example.com")
        end.to_xml.should have_xpath("/format/#{bool}[text()='no']")
      end
    end
  end
  
  describe "setting allowed attributes on a format" do
    it "should have an attribute :foo" do
      class ExampleFormat1 < EncodingDotCom::Format
        allowed_attributes :foo
      end
      ExampleFormat1.allowed_attributes.should == ["foo"]
    end
    
    it "should be able to set allowed attributes cumulatively" do
      class ExampleFormat2 < EncodingDotCom::Format
        allowed_attributes :foo
        allowed_attributes :bar
      end
      ExampleFormat2.allowed_attributes.should == ["foo", "bar"]
    end
  end
  
  describe "setting boolean attributes on a format" do
    it "should also create an allowed attribute" do
      class ExampleFormat3 < EncodingDotCom::Format
        boolean_attributes :foo
      end
      ExampleFormat3.allowed_attributes.should == ["foo"]
    end
    
    it "should create a boolean attribute" do
      class ExampleFormat4 < EncodingDotCom::Format
        boolean_attributes :foo
      end
      ExampleFormat4.boolean_attributes.should == ["foo"]
    end
  end
end

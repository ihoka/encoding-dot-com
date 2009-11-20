require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Encoding.com Thumbnail Format" do

  it "should have an output attribute of 'thumbnail'" do
    EncodingDotCom::ThumbnailFormat.new.output.should == "thumbnail"
  end

  it "should return a ThumbnailFormat if the output is 'thumbnail'" do
    EncodingDotCom::Format.create("output" => "thumbnail").should be_instance_of(EncodingDotCom::ThumbnailFormat)
  end

  def format_xml(attributes={})
    format = EncodingDotCom::ThumbnailFormat.new(attributes)
    Nokogiri::XML::Builder.new {|b| format.build_xml(b, "http://example.com") }.to_xml
  end
  
  it "should produce a format node in the xml output" do
    format_xml.should have_xpath("/format")
  end

  it "should produce an output node in the xml output" do
    format_xml.should have_xpath("/format/output[text()='thumbnail']")
  end

  it "should produce a height node in the xml output" do
    format_xml("height" => 10).should have_xpath("/format/height[text()='10']")
  end

  it "should produce a width node in the xml output" do
    format_xml("width" => 10).should have_xpath("/format/width[text()='10']")
  end

  it "should produce a time node in the xml output" do
    format_xml("time" => 10).should have_xpath("/format/time[text()='10']")
  end

  it "should produce a destination node in the output" do
    format_xml.should have_xpath("/format/destination[text()='http://example.com']")
  end

  describe "valid times" do
    it "can be a number greater than 0.01" do
      lambda { EncodingDotCom::ThumbnailFormat.new("time" => "0") }.should raise_error(EncodingDotCom::IllegalFormatAttribute)
      lambda { EncodingDotCom::ThumbnailFormat.new("time" => "0.5") }.should_not raise_error
    end

    it "can be specified in HH:MM::SS.ms format" do
      lambda { EncodingDotCom::ThumbnailFormat.new("time" => "00:00:01.5") }.should_not raise_error
    end
  end

  describe "valid dimensions" do
    it "should be a positive integer height" do
      lambda { EncodingDotCom::ThumbnailFormat.new("height" => -1) }.should raise_error(EncodingDotCom::IllegalFormatAttribute)
      lambda { EncodingDotCom::ThumbnailFormat.new("height" => 1) }.should_not raise_error      
    end

    it "should be a positive integer width" do
      lambda { EncodingDotCom::ThumbnailFormat.new("width" => -1) }.should raise_error(EncodingDotCom::IllegalFormatAttribute)
      lambda { EncodingDotCom::ThumbnailFormat.new("width" => 1) }.should_not raise_error      
    end
  end
end

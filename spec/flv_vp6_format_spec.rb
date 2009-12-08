require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Encoding.com FLV VP6 Format" do

  it "should have an output attribute of 'thumbnail'" do
    EncodingDotCom::FLVVP6Format.new.output.should == "flv"
  end
      
  it "should produce a format node in the xml output" do
    format_xml.should have_xpath("/format")
  end
  
  it "should produce an output node in the xml output" do
    format_xml.should have_xpath("/format/output[text()='flv']")
  end
  
  it "should produce a video_codec node in the xml output" do
    format_xml.should have_xpath("/format/video_codec[text()='vp6']")
  end
  
  it "should produce a size node in the xml output" do
    format_xml("size" => "16x16").should have_xpath("/format/size[text()='16x16']")
  end
  
  it "should produce a destination node in the output" do
    format_xml.should have_xpath("/format/destination[text()='http://example.com']")
  end

  describe "valid sizes" do
    it "should have widths and heights in multiples of 16" do
      lambda { EncodingDotCom::FLVVP6Format.new("size" => "32x32") }.should_not raise_error
      lambda { EncodingDotCom::FLVVP6Format.new("size" => "33x33") }.should raise_error(EncodingDotCom::IllegalFormatAttribute)
    end
  end

  def format_xml(attributes={})
    format = EncodingDotCom::FLVVP6Format.new(attributes)
    Nokogiri::XML::Builder.new {|b| format.build_xml(b, "http://example.com") }.to_xml
  end
end

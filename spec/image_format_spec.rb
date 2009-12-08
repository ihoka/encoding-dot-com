require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Encoding.com Image Format" do

  it "should have an output attribute of 'thumbnail'" do
    EncodingDotCom::ImageFormat.new.output.should == "image"
  end

  it "should produce an output node in the xml output" do
    format_xml.should have_xpath("/format/output[text()='image']")
  end

  it "should produce an image format node in the xml output" do
    format_xml("image_format" => "jpg").should have_xpath("/format/image_format[text()='jpg']")
  end

  it "should produce a size node in the xml output" do
    format_xml("size" => "10x10").should have_xpath("/format/size[text()='10x10']")
  end

  it "should produce a resize method node in the xml output" do
    format_xml("resize_method" => "crop").should have_xpath("/format/resize_method[text()='crop']")
  end

  it "should produce a resize method node in the xml output" do
    format_xml("quality" => "90").should have_xpath("/format/quality[text()='90']")
  end

  it "should produce a keep aspect ratio node in the xml output" do
    format_xml("keep_aspect_ratio" => true).should have_xpath("/format/keep_aspect_ratio[text()='yes']")
  end

  describe "valid resize method" do
    %w{resize crop combine}.each do |method|
      it "should allow '#{method}'" do
        lambda { format_xml("resize_method" => method) }.should_not raise_error(EncodingDotCom::IllegalFormatAttribute)
      end
    end

    it "should not allow anything else" do
      lambda { format_xml("resize_method" => "foo") }.should raise_error(EncodingDotCom::IllegalFormatAttribute)
    end
  end

  describe "valid image format" do
    %w{jpg png gif}.each do |format|
      it "should allow '#{format}'" do
        lambda { format_xml("image_format" => format) }.should_not raise_error(EncodingDotCom::IllegalFormatAttribute)
      end
    end

    it "should not allow anything else" do
      lambda { format_xml("image_format" => "foo") }.should raise_error(EncodingDotCom::IllegalFormatAttribute)
    end
  end

  describe "valid quality" do
    it "should be between 1 and 100" do
      lambda { format_xml("quality" => 0) }.should raise_error(EncodingDotCom::IllegalFormatAttribute)
      lambda { format_xml("quality" => 101) }.should raise_error(EncodingDotCom::IllegalFormatAttribute)
      lambda { format_xml("quality" => 1) }.should_not raise_error(EncodingDotCom::IllegalFormatAttribute)      
      lambda { format_xml("quality" => 100) }.should_not raise_error(EncodingDotCom::IllegalFormatAttribute)      
    end
  end
  
  def format_xml(attributes={})
    format = EncodingDotCom::ImageFormat.new(attributes)
    Nokogiri::XML::Builder.new {|b| format.build_xml(b, "http://example.com") }.to_xml
  end
end


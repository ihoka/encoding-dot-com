require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Encoding.com Format" do

  it "should have an output attribute" do
    EncodingDotCom::Format.new("output" => "flv").output.should == "flv"
  end

  it "should require an output format" do
    lambda { EncodingDotCom::Format.new }.should raise_error(EncodingDotCom::IllegalFormatAttribute)
  end

  it "should not allow an illegal output format" do
    lambda { EncodingDotCom::Format.new("output" => "foo") }.should raise_error(EncodingDotCom::IllegalFormatAttribute)
  end

  it "should allow flv, fl9, wmv, 3gp, mp4, m4v, ipod, iphone, appletv, psp, zune, mp3, wma and thumbnail output formats" do
    %w{flv fl9 wmv 3gp mp4 m4v ipod iphone appletv psp zune mp3 wma thumbnail}.each do |format|
      lambda { EncodingDotCom::Format.new("output" => format) }.should_not raise_error
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
  end
end

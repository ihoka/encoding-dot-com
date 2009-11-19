require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Encoding.com Thumbnail Format" do

  it "should have an output attribute of 'thumbnail'" do
    EncodingDotCom::ThumbnailFormat.new.output.should == "thumbnail"
  end

  it "should return a ThumbnailFormat if the output is 'thumbnail'" do
    EncodingDotCom::Format.create("output" => "thumbnail").should be_instance_of(EncodingDotCom::ThumbnailFormat)
  end
  
  it "should produce a format node in the xml output" do
    format = EncodingDotCom::ThumbnailFormat.new
    Nokogiri::XML::Builder.new do |b|
      format.build_xml(b)
    end.to_xml.should have_xpath("/format")
  end

  it "should produce an output node in the xml output" do
#    Format.create("output" => "thumbnail") #=> ThumbnailFormat
    
    format = EncodingDotCom::ThumbnailFormat.new
    Nokogiri::XML::Builder.new do |b|
      format.build_xml(b)
    end.to_xml.should have_xpath("/format/output[text()='thumbnail']")
  end
end

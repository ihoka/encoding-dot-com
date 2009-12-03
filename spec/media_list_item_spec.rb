require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "MediaListItem" do
  it "should have a nil date for dates returned from encoding.com like 0000-00-00 00:00:00" do
    node = Nokogiri::XML(<<-END
        <media>
          <mediafile>foo.wmv</mediafile>
          <mediaid>1234</mediaid>
          <mediastatus>Closed</mediastatus>
          <createdate>2009-01-01 12:00:01</createdate>
          <startdate>2009-01-01 12:00:02</startdate>
          <finishdate>0000-00-00 00:00:00</finishdate>
        </media>
        END
                         )
    EncodingDotCom::MediaListItem.new(node).finish_date.should be_nil
  end
end

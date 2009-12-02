module EncodingDotCom
  class MediaListItem
    attr_reader :mediafile, :mediaid, :mediastatus, :createdate, :startdate, :finishdate
  
    def initialize(node)
      @mediafile = (node / "mediafile").text
      @mediaid = (node / "mediaid").text.to_i
      @mediastatus = (node / "mediastatus").text
      @createdate = parse_time_node(node / "createdate")
      @startdate = parse_time_node(node / "startdate")
      @finishdate = parse_time_node(node / "finishdate")
    end

    def parse_time_node(node)
      Time.local *ParseDate.parsedate(node.text)
    end
  end
end

require 'parsedate'

module EncodingDotCom

  # Represents a video or image in the encoding.com queue
  class MediaListItem
    attr_reader :media_file, :media_id, :media_status, :create_date, :start_date, :finish_date

    # Creates a MediaListItem, given a <media> Nokogiri::XML::Node
    #
    # See the encoding.com documentation for GetMediaList for more details
    def initialize(node)
      @media_file = (node / "mediafile").text
      @media_id = (node / "mediaid").text.to_i
      @media_status = (node / "mediastatus").text
      @create_date = parse_time_node(node / "createdate")
      @start_date = parse_time_node(node / "startdate")
      @finish_date = parse_time_node(node / "finishdate")
    end

    private

    def parse_time_node(node)
      time_elements = ParseDate.parsedate(node.text)
      Time.local *time_elements unless time_elements.all? {|e| e.nil? || e == 0 }
    end
  end
end

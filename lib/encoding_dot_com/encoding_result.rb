require 'ostruct'

module EncodingDotCom
  # http://www.encoding.com/wdocs/ApiDoc#EncodingResultXML
  class EncodingResult
    class << self
      def decode(xml)
        result = Nokogiri::XML(xml)
        
        formats = (result / "format").map do |node|
          attributes = {}
          values = [:output, :destination, :status, :description, :suggestion].map do |attr|
            attributes[attr] = (node / attr.to_s).text
          end
          
          OpenStruct.new(attributes)
        end
        
        OpenStruct.new(
          :mediaid     => (result / "mediaid").text.to_i,
          :source      => (result / "source").text,
          :status      => (result / "result/status").text,
          :description => (result / "result/description").text,
          :formats     => formats
        )
      end
    end
  end
end
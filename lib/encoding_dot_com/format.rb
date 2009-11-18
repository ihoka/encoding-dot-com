module EncodingDotCom
  class IllegalFormatAttribute < StandardError
  end

  class Format
    ALLOWED_OUTPUT_FORMATS = %w{flv fl9 wmv 3gp mp4 m4v ipod iphone appletv psp zune mp3 wma thumbnail}.freeze

    attr_reader :output
    
    def initialize(attributes={})
      @output = attributes["output"]
      raise IllegalFormatAttribute.new unless ALLOWED_OUTPUT_FORMATS.include?(@output)
    end
    
    def build_xml(builder)
      builder.format {
        builder.output @output
      }
    end
  end
end

module EncodingDotCom
  class IllegalFormatAttribute < StandardError
  end

  class Format
    ALLOWED_OUTPUT_FORMATS = %w{flv fl9 wmv 3gp mp4 m4v ipod iphone appletv psp zune mp3 wma thumbnail}.freeze

    attr_reader :output
    
    def initialize(attributes={})
      @output = attributes["output"]
      @width = attributes["width"] || 0
      @height = attributes["height"] || 0
      raise IllegalFormatAttribute.new unless ALLOWED_OUTPUT_FORMATS.include?(@output)
    end

    def size
      "#{@width}x#{@height}" if size_specified?
    end

    def build_xml(builder)
      builder.format {
        builder.output @output
        if size_specified?
          builder.size self.size
        end
      }
    end

    private

    def size_specified?
      @height != 0 || @width != 0
    end
  end
end

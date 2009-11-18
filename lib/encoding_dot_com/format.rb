module EncodingDotCom
  class IllegalFormatAttribute < StandardError
  end

  class Format
    ALLOWED_OUTPUT_FORMATS = %w{flv fl9 wmv 3gp mp4 m4v ipod iphone appletv psp zune mp3 wma thumbnail}.freeze

    attr_reader :output
    
    def initialize(attributes={})
      @output = attributes["output"]
      raise IllegalFormatAttribute.new unless ALLOWED_OUTPUT_FORMATS.include?(@output)

      (class << self; self; end).send :include, EncodingDotCom.const_get("AttributeRestrictions" + @output.capitalize)

      @width = attributes["width"] || default_width
      @height = attributes["height"] || default_height

      raise IllegalFormatAttribute.new unless valid_attributes?
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

    def valid_attributes?
      valid_size?
    end

    def valid_size?
      true
    end
    
    def default_width
      0
    end

    def default_height
      0
    end
    
    def size_specified?
      @height != 0 || @width != 0
    end
  end
end

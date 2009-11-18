module EncodingDotCom
  class IllegalFormatAttribute < StandardError
  end

  class Format
    ALLOWED_OUTPUT_FORMATS = %w{flv fl9 wmv 3gp mp4 m4v ipod iphone appletv psp zune vp6 mp3 wma thumbnail}.freeze

    attr_reader :output, :size
    
    def initialize(attributes={})
      @output = attributes["output"]
      raise IllegalFormatAttribute.new unless ALLOWED_OUTPUT_FORMATS.include?(@output)

      (class << self; self; end).send :include, EncodingDotCom.const_get("AttributeRestrictions" + @output.capitalize)

      @size = attributes["size"]
      
      raise IllegalFormatAttribute.new unless valid_attributes?
    end

    def build_xml(builder)
      builder.format {
        builder.output @output
        if size
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
  end
end

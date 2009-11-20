module EncodingDotCom
  class ThumbnailFormat < Format
    ALLOWED_ATTRIBUTES = %w{output time width height}.freeze

    # Define reader methods for all the allowed attributes
    ALLOWED_ATTRIBUTES.each do |attr|
      define_method(attr) { @attributes[attr] }
    end
    
    def initialize(attributes={})
      @attributes = attributes.merge("output" => "thumbnail")
      validate_attributes
    end

    def validate_attributes
      validate_time
      validate_height
      validate_width
    end
    
    def build_xml(builder, destination_url=nil)
      builder.format {
        builder.output self.output
      }
    end

    private
    
    def validate_time
      unless time.nil? || time.to_f > 0.01 || time.to_s =~ /\d\d:[0-5]\d:[0-5]\d(\.\d+)?/
        raise IllegalFormatAttribute.new("Time must be a number greater than 0.01 or HH:MM:SS.ms, was #{time}")
      end
    end

    def validate_height
      unless height.nil? || height.to_i > 0
        raise IllegalFormatAttribute.new("Height must be a positive integer, was #{height}")
      end
    end

    def validate_width
      unless width.nil? || width.to_i > 0
        raise IllegalFormatAttribute.new("Width must be a positive integer, was #{width}")
      end
    end
  end
end
  

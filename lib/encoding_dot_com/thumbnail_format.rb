module EncodingDotCom
  class ThumbnailFormat
    ALLOWED_ATTRIBUTES = %w{output time width height}.freeze

    # Define reader methods for all the allowed attributes
    ALLOWED_ATTRIBUTES.each do |attr|
      define_method(attr) { @attributes[attr] }
    end
    
    def initialize(attributes={})
      @attributes = attributes.merge("output" => "thumbnail")
      raise IllegalFormatAttribute.new unless valid_attributes?      
    end

    def valid_attributes?
      valid_time? && valid_height? && valid_width?
    end
    
    def build_xml(builder, destination_url=nil)
      builder.format {
        builder.output self.output
      }
    end

    private
    
    def valid_time?
      time.nil? || time.to_f > 0.01 || time.to_s =~ /\d\d:[0-5]\d:[0-5]\d(\.\d+)?/
    end

    def valid_height?
      height.nil? || height.to_i > 0
    end

    def valid_width?
      width.nil? || width.to_i > 0
    end
  end
end
  

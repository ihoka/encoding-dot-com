module EncodingDotCom
  # A Thumbnail output format
  class ThumbnailFormat < Format #:nodoc:
    allowed_attributes :output, :time, :width, :height

    # Creates a new ThumbnailFormat. You should be calling
    # Format.create(attributes) rather than this constructor directly.
    def initialize(attributes={})
      @attributes = attributes.merge("output" => "thumbnail")
      validate_attributes
    end

    def validate_attributes
      validate_time
      validate_height
      validate_width
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
  

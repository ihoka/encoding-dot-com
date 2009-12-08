module EncodingDotCom
  class ImageFormat < Format
    allowed_attributes :output, :image_format, :size, :resize_method, :quality
    boolean_attributes :keep_aspect_ratio

    def initialize(attributes={})
      @attributes = attributes.merge("output" => "image")
      validate_attributes      
    end

    private

    def validate_attributes
      validate_image_format
      validate_resize_method
    end

    def validate_image_format
      unless image_format.nil? || %w{jpg png gif}.include?(image_format)
        raise IllegalFormatAttribute.new("image_format should be one of jpg, png or gif.")
      end
    end
    
    def validate_resize_method
      unless resize_method.nil? || %w{resize crop combine}.include?(resize_method)
        raise IllegalFormatAttribute.new("resize_method should be one of resize, crop or combine.")
      end
    end
    
  end
end

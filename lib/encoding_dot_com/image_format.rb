module EncodingDotCom
  class ImageFormat < Format
    allowed_attributes :output, :image_format, :size, :resize_method, :quality
    boolean_attributes :keep_aspect_ratio

    def initialize(attributes={})
      @attributes = attributes.merge("output" => "image")
    end
  end
end

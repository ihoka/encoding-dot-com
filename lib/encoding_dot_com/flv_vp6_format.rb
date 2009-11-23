module EncodingDotCom
  class FLVVP6Format < Format
    allowed_attributes :output, :video_codec, :size, :destination, :bitrate, :audio_bitrate, :audio_sample_rate, :audio_channels_number, :framerate
    
    def initialize(attributes={})
      @attributes = attributes.merge("output" => "flv", "video_codec" => "vp6")
      validate_attributes
    end

    def validate_attributes
      validate_size
    end
        
    private
    
    def validate_size
      return if size.nil?
      if video_codec == "vp6" && ! size.split("x").all? {|n| (n.to_i % 16) == 0 }
        raise IllegalFormatAttribute.new("Dimensions #{} should be multiples of 16")
      end
    end
    
  end
end
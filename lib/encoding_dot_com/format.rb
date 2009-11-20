module EncodingDotCom
  class Format
    ALLOWED_OUTPUT_FORMATS = %w{flv fl9 wmv 3gp mp4 m4v ipod iphone appletv psp zune mp3 wma}.freeze
    ALLOWED_ATTRIBUTES = %w{output size bitrate framerate video_codec audio_bitrate audio_sample_rate audio_codec audio_channels_number audio_volume two_pass cbr maxrate minrate bufsize keyframe start duration rc_init_occupancy deinterlacing crop_top crop_left crop_right crop_bottom add_meta logo_source logo_x logo_y logo_mode logo_threshold turbo}.freeze

    # Define reader methods for all the allowed attributes
    ALLOWED_ATTRIBUTES.each do |attr|
      define_method(attr) { @attributes[attr] }
    end
    
    def initialize(attributes={})
      @attributes = attributes
      check_valid_output_format
      mixin_output_attribute_restrictions
      raise IllegalFormatAttribute.new unless valid_attributes?
    end

    def self.create(attributes)
      if attributes["output"] == "thumbnail"
        ThumbnailFormat.new(attributes)
      else
        Format.new(attributes)
      end
    end
    
    def build_xml(builder, destination_url=nil)
      logo_attributes, other_attributes = ALLOWED_ATTRIBUTES.partition {|a| a[0..3] == "logo" }
      
      builder.format {
        builder.destination destination_url
        other_attributes.each {|attr| builder.send(attr, @attributes[attr]) if @attributes[attr] }
        if logo_attributes.any? {|attr| @attributes[attr] }
          builder.logo {
            logo_attributes.each {|attr| builder.send(attr, @attributes[attr]) if @attributes[attr] }
          }
        end
      }
    end

    private
    
    def check_valid_output_format
      unless ALLOWED_OUTPUT_FORMATS.include?(@attributes["output"])
        raise IllegalFormatAttribute.new("Output format #{@attributes["output"]} is not allowed.")
      end
    end
    
    def mixin_output_attribute_restrictions
      module_name = "AttributeRestrictions#{@attributes["output"].capitalize}"
      restrictions = EncodingDotCom.const_get(module_name)
      (class << self; self; end).send(:include, restrictions)
    end
    
    def valid_attributes?
      valid_size? && valid_video_codec?
    end

    def valid_size?
      true
    end

    def valid_video_codec?
      true
    end
  end
end

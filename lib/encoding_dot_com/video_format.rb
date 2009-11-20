module EncodingDotCom
  class VideoFormat < Format
    ALLOWED_OUTPUT_FORMATS = %w{flv fl9 wmv 3gp mp4 m4v ipod iphone appletv psp zune mp3 wma}.freeze
    BOOLEAN_ATTRIBUTES = %w{two_pass cbr deinterlacing add_meta turbo}.freeze
    
    allowed_attributes :output, :size, :bitrate, :framerate, :video_codec, :audio_bitrate, :audio_sample_rate, :audio_codec, :audio_channels_number, :audio_volume, :two_pass, :cbr, :maxrate, :minrate, :bufsize, :keyframe, :start, :duration, :rc_init_occupancy, :deinterlacing, :crop_top, :crop_left, :crop_right, :crop_bottom, :add_meta, :logo_source, :logo_x, :logo_y, :logo_mode, :logo_threshold, :turbo
    
    def initialize(attributes={})
      @attributes = attributes
      check_valid_output_format
      mixin_output_attribute_restrictions
      validate_attributes
    end

    def build_xml(builder, destination_url=nil)
      logo_attributes, other_attributes = self.class.allowed_attributes.partition {|a| a[0..3] == "logo" }
      
      builder.format {
        builder.destination destination_url
        other_attributes.each do |attr|
          unless @attributes[attr].nil?
            if BOOLEAN_ATTRIBUTES.include?(attr)
              val = (@attributes[attr] ? "yes" : "no")
            else
              val = @attributes[attr]
            end
            builder.send(attr, val)
          end
        end
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
    
    def validate_attributes
      validate_video_codec
      validate_size
    end

    def validate_size
    end

    def validate_video_codec
    end
  end
end

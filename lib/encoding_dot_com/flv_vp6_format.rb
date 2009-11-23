module EncodingDotCom
  class FLVVP6Format < Format
    allowed_attributes :output, :video_codec, :size, :destination
    BOOLEAN_ATTRIBUTES = %w{}
    
    def initialize(attributes={})
      @attributes = attributes.merge("output" => "flv", "video_codec" => "vp6")
      validate_attributes
    end

    def validate_attributes
      validate_size
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
    
    def validate_size
      return if size.nil?
      if video_codec == "vp6" && ! size.split("x").all? {|n| (n.to_i % 16) == 0 }
        raise IllegalFormatAttribute.new("Dimensions #{} should be multiples of 16")
      end
    end
    
  end
end
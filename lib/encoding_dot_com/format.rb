module EncodingDotCom
  class Format
    class << self
      def create(attributes)
        if attributes["output"] == "thumbnail"
          ThumbnailFormat.new(attributes)
        elsif attributes["output"] == "flv" && attributes["video_codec"] == "vp6"
          FLVVP6Format.new(attributes)
        else
          VideoFormat.new(attributes)
        end
      end

      def allowed_attributes(*attrs)
        @allowed_attributes ||= []
        if attrs.empty?
          @allowed_attributes
        else
          @allowed_attributes += attrs.map {|a| a.to_s }.each { |attr| define_method(attr) { @attributes[attr] } }
        end
      end
      
      def boolean_attributes(*attrs)
        @boolean_attributes ||= []
        if attrs.empty?
          @boolean_attributes  
        else
          allowed_attributes *attrs
          @boolean_attributes += attrs.map {|a| a.to_s }
        end
      end
    end
    
    def build_xml(builder, destination_url=nil)
      logo_attributes, other_attributes = self.class.allowed_attributes.partition {|a| a[0..3] == "logo" }

      builder.format {
        builder.destination destination_url
        other_attributes.each do |attr|
          unless @attributes[attr].nil?
            if self.class.boolean_attributes.include?(attr)
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
  end
end

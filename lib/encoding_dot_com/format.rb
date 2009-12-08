module EncodingDotCom
  # Base class for all formats sent to encoding.com
  #
  # You should create formats by calling +create+ with format attributes.
  class Format
    class << self
      # Factory method that returns an appropriate Format. The
      # +output+ attribute is required, others are optional (see the
      # encoding.com documentation for full list of attributes).
      def create(attributes)
        if attributes["output"] == "thumbnail"
          ThumbnailFormat.new(attributes)
        elsif attributes["output"] == "flv" && attributes["video_codec"] == "vp6"
          FLVVP6Format.new(attributes)
        elsif attributes["output"] == "image"
          ImageFormat.new(attributes)
        else
          VideoFormat.new(attributes)
        end
      end

      def allowed_attributes(*attrs) #:nodoc:
        @allowed_attributes ||= []
        if attrs.empty?
          @allowed_attributes
        else
          @allowed_attributes += attrs.map {|a| a.to_s }.each { |attr| define_method(attr) { @attributes[attr] } }
        end
      end
      
      def boolean_attributes(*attrs) #:nodoc:
        @boolean_attributes ||= []
        if attrs.empty?
          @boolean_attributes  
        else
          allowed_attributes *attrs
          @boolean_attributes += attrs.map {|a| a.to_s }
        end
      end
    end

    # Builds the XML for this format.
    #
    # +builder+:: a Nokogiri builder, declared with a block
    # +destination_url+:: where the encoded file should be placed. See
    #                     the encoding.com documentation for details.
    def build_xml(builder, destination_url=nil)
      logo_attributes, other_attributes = self.class.allowed_attributes.partition {|a| a[0..3] == "logo" }

      builder.format {
        builder.destination destination_url
        other_attributes.each do |attr|
          builder.send(attr, output_value(attr)) unless @attributes[attr].nil?
        end
        if logo_attributes.any? {|attr| @attributes[attr] }
          builder.logo {
            logo_attributes.each {|attr| builder.send(attr, output_value(attr)) if @attributes[attr] }
          }
        end
      }
    end

    private

    # Returns a value suitable for the format XML - i.e. translates
    # booleans to yes/no.
    def output_value(key)
      if self.class.boolean_attributes.include?(key)
        (@attributes[key] ? "yes" : "no")
      else
        @attributes[key]
      end
    end
  end
end

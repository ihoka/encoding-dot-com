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
        if attrs.empty?
          # TODO fix if allowed_attributes has not yet been set
          @allowed_attributes
        else
          @allowed_attributes = attrs.map {|a| a.to_s }.freeze
          @allowed_attributes.each do |attr|
            define_method(attr) { @attributes[attr] }
          end
        end
      end
    end
  end
end

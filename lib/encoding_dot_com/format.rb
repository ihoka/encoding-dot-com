module EncodingDotCom
  class Format
    def self.create(attributes)
      if attributes["output"] == "thumbnail"
        ThumbnailFormat.new(attributes)
      else
        VideoFormat.new(attributes)
      end
    end
  end
end

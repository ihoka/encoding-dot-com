module EncodingDotCom
  module AttributeRestrictionsZune
    def validate_size
      allowed_sizes = ["320x120", "320x180", "320x0", "0x120", "0x180"]
      unless size.nil? || allowed_sizes.include?(size)
        raise IllegalFormatAttribute.new("Size can only be one of #{allowed_sizes.join(',')} but was #{size}")
      end
    end
  end

  module AttributeRestrictionsIpod
    def validate_size
      allowed_sizes = ["320x240", "640x480"]
      unless size.nil? || allowed_sizes.include?(size)
        raise IllegalFormatAttribute.new("Size can only be one of #{allowed_sizes.join(',')} but was #{size}")
      end
    end
  end

  module AttributeRestrictionsFlv
    def validate_video_codec
      allowed_codecs = ["flv", "libx264", "vp6"]
      unless video_codec.nil? || allowed_codecs.include?(video_codec)
        raise IllegalFormatAttribute.new("Video codec can only be one of #{allowed_codecs.join(',')} but was #{video_codec}")
      end
    end
    
    def validate_size
      return if size.nil?
      if video_codec == "vp6" && ! size.split("x").all? {|n| (n.to_i % 16) == 0 }
        raise IllegalFormatAttribute.new("Dimensions #{} should be multiples of 16")
      end
    end
  end

  module AttributeRestrictionsMp4
    def validate_video_codec
      allowed_codecs = ["mpeg4", "libx264"]
      unless video_codec.nil? || allowed_codecs.include?(video_codec)
        raise IllegalFormatAttribute.new("Video codec can only be one of #{allowed_codecs.join(',')} but was #{video_codec}")
      end
    end
  end

  module AttributeRestrictionsFl9
  end

  module AttributeRestrictionsWmv
  end

  module AttributeRestrictions3gp
  end
  
  module AttributeRestrictionsM4v
  end

  module AttributeRestrictionsIphone
  end
  
  module AttributeRestrictionsAppletv
  end

  module AttributeRestrictionsPsp
  end
  
  module AttributeRestrictionsMp3
  end
  
  module AttributeRestrictionsWma
  end
  
  module AttributeRestrictionsThumbnail
  end
end

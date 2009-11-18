module EncodingDotCom

  module AttributeRestrictionsZune
    def valid_size?
      size.nil? || ["320x120", "320x180", "320x0", "0x120", "0x180"].include?(size)
    end
  end

  module AttributeRestrictionsIpod
    def valid_size?
      size.nil? || ["320x240", "640x480"].include?(size)
    end
  end

  module AttributeRestrictionsVp6
    def valid_size?
      size.nil? || size.split("x").all? {|n| (n.to_i % 16) == 0 }
    end
  end

  module AttributeRestrictionsFlv
  end

  module AttributeRestrictionsFl9
  end

  module AttributeRestrictionsWmv
  end

  module AttributeRestrictions3gp
  end

  module AttributeRestrictionsMp4
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

module EncodingDotCom
  # Error raised if there is an http-level problem accessing the
  # encoding.com API.
  class AvailabilityError < StandardError
  end

  # Error raised if there is an problem with the message sent to
  # encoding.com API.
  class MessageError < StandardError
  end

  # Error raised if a format's attribute has an illegal value
  class IllegalFormatAttribute < StandardError
  end
end

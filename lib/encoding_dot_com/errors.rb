module EncodingDotCom
  # Error raised if there is an http-level problem accessing the
  # encoding.com API.
  class AvailabilityError < StandardError
  end

  # Error raiseed if there is an problem with the message sent to
  # encoding.com API.
  class MessageError < StandardError
  end

  class IllegalFormatAttribute < StandardError
  end
end

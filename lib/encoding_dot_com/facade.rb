require 'nokogiri'

module EncodingDotCom
  # Error raised if there is an http-level problem accessing the
  # encoding.com API.
  class AvailabilityError < StandardError
  end

  # Error raiseed if there is an problem with the message sent to
  # encoding.com API.
  class MessageError < StandardError
  end

  # A remote facade to the encoding.com API.
  #
  # The facade is stateless and can be reused for multiple requests.
  class Facade
    # Where encoding.com expects messages to be posted to.
    ENDPOINT = "http://manage.encoding.com/"

    # Creates a new facacde given an encoding.com user id & key, and
    # an HTTP library implementation.
    #
    # +http+ should respond to post, and return an object responding to
    # +#code+ and +#to_s+
    def initialize(user_id, user_key, http)
      @user_id, @user_key, @http = user_id, user_key, http
    end

    def process(source, destination, format)
      make_request("<query><userid>#{@user_id}</userid><userkey>#{@user_key}</userkey><action>AddMedia</action><source>#{source}</source></query>")
    end

    private

    def make_request(xml)
      response = @http.post(ENDPOINT, :xml => xml)
      raise AvailabilityError.new unless response.code.to_s == "200"
      check_for_response_errors(response.to_s)
      true
    end

    def check_for_response_errors(xml)
      errors = Nokogiri::XML(xml).xpath("/response/errors/error").map {|e| e.text }
      raise MessageError.new(errors.join(", ")) unless errors.empty?
    end
  end
end

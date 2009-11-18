require 'nokogiri'

module EncodingDotCom
  class AvailabilityError < StandardError
  end

  class MessageError < StandardError
  end
  
  class Facade
    ENDPOINT = "http://manage.encoding.com/"
    
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

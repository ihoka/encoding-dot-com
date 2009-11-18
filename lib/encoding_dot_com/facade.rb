module EncodingDotCom
  class AvailabilityError < StandardError
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
      return true if response.code.to_s == "200"
      raise AvailabilityError.new if response.code.to_s[0..0] == "5"
    end
  end
end

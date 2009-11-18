require 'nokogiri'

module EncodingDotCom
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

    def add_and_process(source, destination, formats)
      query = Nokogiri::XML::Builder.new do |q|
        q.query {
          q.userid @user_id
          q.userkey @user_key
          q.action "AddMedia"
          q.source source
          formats.each {|format| format.build_xml(q) }
        }
      end
      make_request(query.to_xml)
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

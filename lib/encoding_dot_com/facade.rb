require 'nokogiri'
require 'parsedate'

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

    # Add a video/image to the encoding.com queue to be encoded in
    # various formats.
    #
    # Source is the source url
    # formats is a hash of destination urls => format objects
    def add_and_process(source, formats={})
      response = make_request("AddMedia") do |q|      
        q.source source
        formats.each {|url, format| format.build_xml(q, url) }
      end
      media_id = response.xpath("/response/MediaID").text
      media_id.to_i if media_id
    end

    # Returns the status string of a particular media item in the
    # encoding.com queue. The status will be for the job as a whole,
    # rather than individual ouput formats
    def status(media_id)
      response = make_request("GetStatus") do |q|
        q.mediaid media_id
      end
      response.xpath("/response/status").text
    end

    # Returns a list of media in the encoding.com queue
    def list
      make_request("GetMediaList").xpath("/response/media").map {|node| MediaListItem.new(node) }
    end

    # Cancels a media item in the encoding.com queue
    def cancel(media_id)
      make_request("CancelMedia") do |q|
        q.mediaid media_id
      end
    end

    def info(media_id)
      response = make_request("GetMediaInfo") do |q|
        q.mediaid media_id
      end
    end

    private

    def make_request(action_name, &block)
      query = build_query(action_name, &block)
      response = @http.post(ENDPOINT, :xml => query)
      raise AvailabilityError.new unless response.code.to_s == "200"
      xml = Nokogiri::XML(response.to_s)
      check_for_response_errors(xml)
      xml
    end

    def build_query(action)
      query = Nokogiri::XML::Builder.new do |q|
        q.query {
          q.userid @user_id
          q.userkey @user_key
          q.action action
          yield q if block_given?
        }
      end.to_xml
    end
    
    def check_for_response_errors(xml)
      errors = xml.xpath("/response/errors/error").map {|e| e.text }
      raise MessageError.new(errors.join(", ")) unless errors.empty?
    end
  end
end

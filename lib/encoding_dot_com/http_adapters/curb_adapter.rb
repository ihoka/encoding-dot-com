module EncodingDotCom
  module HttpAdapters

    Response = Struct.new(:code, :body)

    # Wraps the curb[http://curb.rubyforge.org/] library for use with
    # the Queue.
    class CurbAdapter
      def initialize
        require 'curb'
      end

      # Makes a POST request. Raises an AvailabilityError if the
      # request times out or has other problems.
      def post(url, parameters={})
        curl = Curl::Easy.new(url) {|c| c.follow_location = true }
        post_parameters = parameters.map {|k,v| Curl::PostField.content(k.to_s, v.to_s) }
        begin
          curl.http_post(*post_parameters)
        rescue => e
          raise AvailabilityError.new(e.message)
        end
        Response.new(curl.response_code.to_s, curl.body_str)
      end
    end
  end
end

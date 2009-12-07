module EncodingDotCom
  module HttpAdapters

    # Wraps the Net/HTTP library for use with the Queue.
    class NetHttpAdapter
      def initialize
        require 'net/http'
      end

      # Makes a POST request. Raises an AvailabilityError if the
      # request times out or has other problems.
      def post(url, parameters={})
        Net::HTTP.post_form(URI.parse(url), parameters)
      rescue => e
        raise AvailabilityError.new(e.message)
      rescue Timeout::Error => e
        raise AvailabilityError.new(e.message)          
      end
    end
    
  end
end

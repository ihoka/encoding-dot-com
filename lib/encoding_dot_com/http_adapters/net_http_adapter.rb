module EncodingDotCom
  module HttpAdapters

    class NetHttpAdapter
      def initialize
        require 'net/http'
      end

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

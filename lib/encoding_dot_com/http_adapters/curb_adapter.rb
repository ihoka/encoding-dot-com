module EncodingDotCom
  module HttpAdapters

    class CurbAdapter
      def initialize
        require 'curb'
      end

      def post(url, parameters={})
        curl = Curl::Easy.new(url) {|c| c.follow_location = true }
        post_parameters = parameters.map {|k,v| Curl::PostField.content(k.to_s, v.to_s) }
        curl.http_post(*post_parameters)
      end
    end
    
  end
end

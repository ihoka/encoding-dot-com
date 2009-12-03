module EncodingDotCom
  module HttpAdapters

    Response = Struct.new(:code, :body)
    
    class CurbAdapter
      def initialize
        require 'curb'
      end

      def post(url, parameters={})
        curl = Curl::Easy.new(url) {|c| c.follow_location = true }
        post_parameters = parameters.map {|k,v| Curl::PostField.content(k.to_s, v.to_s) }
        curl.http_post(*post_parameters)
        Response.new(curl.response_code.to_s, curl.body_str)
      end
    end
    
  end
end

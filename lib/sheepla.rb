require 'rubygems'
require 'net/https'
require 'uri'
require 'nokogiri'

module Sheepla
  class ApiError < StandardError; end

  class API
    BASE_URL = 'https://api.sheepla.com/'

    attr_accessor :api_key, :uri, :http

    def initialize(api_key)
      @api_key = api_key
    end

    def order_synchronization(params)
      body = Nokogiri::XML::Builder.new do |xml|
        authentication(xml)
      end
      
      request_method(body)
    end

    protected

      def authentication(xml)
        xml.authentication do
          xml.apiKey @api_key
        end
      end

      def connection
        @uri = URI.parse(BASE_URL)
        @http = Net::HTTP.new(uri.host, uri.port)
        @http.use_ssl = true
      end


      def request_method(params)
        connection()
        request = Net::HTTP::Post.new(@uri.request_uri)
        request['content-type'] = 'text/xml'
        request['content-length'] = params.to_s.size
        request.body = params.to_xml
        response = @http.request(request)

        raise ApiError.new("401 Unauthorized") if response.code.to_i == 401
        raise ApiError.new("400 Bad Request") if response.code.to_i == 400
        raise ApiError.new("500 Internal Sever Error") if response.code.to_i == 500
        raise ApiError.new("501 Not implemented") if response.code.to_i == 501

        unless response.code.to_i == 200
          raise ApiError.new("Response status code: #{response.code}")
        end

        Hash.from_xml(response.body)
      end
  end
end

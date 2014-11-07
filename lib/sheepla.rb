require 'rubygems'
require 'net/https'
require 'uri'
require 'nokogiri'
require 'ostruct'

module Sheepla
  class ApiError < StandardError; end

  class API
    BASE_URL = 'https://api.sheepla.com/'

    attr_accessor :api_key, :uri, :http

    def initialize(api_key)
      @api_key = api_key
    end

    def get_metro_stations
      connection('getMetroStations')
      body = Nokogiri::XML::Builder.new do |xml|
        xml.getMetroStationsRequest xmlns: "http://www.sheepla.pl/webapi/1_0" do
          authentication(xml)
        end
      end

      request_method(body)
    end

    def create_order(params)
      raise ApiError.new("Order parameters don't contain all obligatory keys") unless validate_order(params)
      order = params.clone

      connection('createOrder')

      body = Nokogiri::XML::Builder.new do |xml|
        xml.createOrderRequest xmlns: "http://www.sheepla.pl/webapi/1_0" do
          authentication(xml)
          xml.orders do
            xml.order do
              xml.orderValue order['order_value']
              xml.orderValueCurrency order['order_currency']
              xml.externalDeliveryTypeId order['external_delivery_type_id']
              xml.externalDeliveryTypeName order['external_delivery_type_name']
              xml.externalPaymentTypeId order['external_payment_type_id']
              xml.externalPaymentTypeName order['external_payment_type_name']
              xml.externalCarrierId order['external_carrier_id']
              xml.externalCarrierName order['external_carrier_name']
              xml.externalCountyId order['external_country_id']
              xml.externalBuyerId order['external_buyer_id']
              xml.externalOrderId order['external_order_id']
              xml.shipmentTemplate order['shipment_template']
              xml.comments order['comments']
              xml.createdOn order['created_on']
              xml.deliveryPrice order['delivery_price']
              xml.deliveryPriceCurrency order['delivery_price_currency']
              xml.deliveryAddress do
                xml.street order['delivery_address']['street']
                xml.zipCode order['delivery_address']['zip_code']
                xml.city order['delivery_address']['city']
                xml.countryAlpha2Code order['delivery_address']['country_alpha2_code']
                xml.firstName order['delivery_address']['first_name']
                xml.lastName order['delivery_address']['last_name']
                xml.companyName order['delivery_address']['company_name']
                xml.phone order['delivery_address']['phone']
                xml.email order['delivery_address']['email']
              end
              xml.deliveryOptions do
                xml.cod order['delivery_options'].delete('cod')
                xml.insurance order['delivery_options'].delete('insurance')
                order['delivery_options'].each do |delivery_partner, delivery_partner_data|
                  xml.send(delivery_partner) do
                    delivery_partner_data.each do |k,v|
                      xml.send(k, v)
                    end
                  end
                end
              end if order['delivery_options']
            end
          end
        end
      end

      request_method(body)
    end

    protected
      def authentication(xml)
        xml.authentication do
          xml.apiKey @api_key
        end
      end

      def connection(method)
        @uri = URI.parse(BASE_URL + method)
        @http = Net::HTTP.new(uri.host, uri.port)
        @http.use_ssl = true
      end


      def request_method(params)
        body = params.to_xml
        request = Net::HTTP::Post.new(@uri.request_uri)
        request['content-type'] = 'text/xml'
        request['content-length'] = body.size
        request.body = body
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

      def validate_order(params)
        params['order_value'] &&
        params['order_currency'] &&
        params['external_delivery_type_id'] &&
        params['external_delivery_type_name'] &&
        params['external_payment_type_id'] &&
        params['external_payment_type_name'] &&
        params['external_carrier_id'] &&
        params['external_carrier_name'] &&
        params['external_country_id'] &&
        params['external_buyer_id'] &&
        params['external_order_id'] &&
        params['shipment_template'] &&
        params['comments'] &&
        params['created_on'] &&
        params['delivery_price'] &&
        params['delivery_price_currency'] &&
        params['delivery_address'] &&
        params['delivery_address']['street'] &&
        params['delivery_address']['zip_code'] &&
        params['delivery_address']['city'] &&
        params['delivery_address']['country_alpha2_code'] &&
        params['delivery_address']['first_name'] &&
        params['delivery_address']['last_name'] &&
        params['delivery_address']['company_name'] &&
        params['delivery_address']['phone'] &&
        params['delivery_address']['email']
      end
  end
end

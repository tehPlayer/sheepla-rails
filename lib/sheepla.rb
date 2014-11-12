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

    def create_order(params)
      order = params.deep_transform_keys{ |key| key.to_s.camelize(:lower) }

      raise ApiError.new("Order parameters don't contain all obligatory keys") unless validate_order(order)

      connection('createOrder')
      request_method(build_order(order))
    end

    def add_shipment_to_order(external_order_id)
      connection('addShipmentToOrder')

      body = body_wrapper('addShipmentToOrderRequest') do |xml|
        xml.orders do
          xml.order do
            xml.externalOrderId external_order_id
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

      def body_wrapper(method)
        Nokogiri::XML::Builder.new(encoding: 'utf-8') do |xml|
          xml.send(method, xmlns: "http://www.sheepla.pl/webapi/1_0") do
            authentication(xml)
            yield xml
          end
        end
      end

      def build_order(order)
        address = order.delete('deliveryAddress')
        items = order.delete('orderItems') 
        options = order.delete('deliveryOptions')
        
        body_wrapper('createOrderRequest') do |xml|
          xml.orders do
            xml.order do
              add_other_order_data(xml, order)

              add_delivery_address(xml, address)
              add_order_items(xml, items) if items
              add_delivery_options(xml, options) if options
              # xml.orderValue order['order_value']
              # xml.orderValueCurrency order['order_currency']
              # xml.externalDeliveryTypeId order['external_delivery_type_id']
              # xml.externalDeliveryTypeName order['external_delivery_type_name']
              # xml.externalPaymentTypeId order['external_payment_type_id']
              # xml.externalPaymentTypeName order['external_payment_type_name']
              # xml.externalCarrierName order['external_carrier_name']
              # xml.externalCarrierId order['external_carrier_id']
              # xml.externalCountryId order['external_country_id']
              # xml.externalBuyerId order['external_buyer_id']
              # xml.externalOrderId order['external_order_id']
              # xml.shipmentTemplate order['shipment_template']
              # xml.comments order['comments']
              # xml.createdOn order['created_on'].to_s
              # xml.deliveryPrice order['delivery_price']
              # xml.deliveryPriceCurrency order['delivery_price_currency']

            end
          end
        end
      end

      def add_delivery_address(xml, delivery_address)
        xml.deliveryAddress do
          delivery_address.each do |delivery_key, delivery_value|
            xml.send(delivery_key, delivery_value)
          end
        end
      end

      def add_order_items(xml, order_items)
        xml.orderItems do
          order_items.each do |order_item|
            xml.orderItem do
              order_item.each do |k, v|
                xml.send(k, v)
              end
            end
          end
        end
      end

      def add_delivery_options(xml, delivery_options)
        xml.deliveryOptions do
          xml.cod delivery_options.delete('cod')
          xml.insurance delivery_options.delete('insurance')
          delivery_options.each do |delivery_partner, delivery_partner_data|
            xml.send(delivery_partner) do
              delivery_partner_data.each do |k,v|
                xml.send(k, v)
              end
            end
          end
        end 
      end

      def add_other_order_data(xml, order_data)
        order_data.each do |k,v|
          xml.send(k, v)
        end        
      end

      def validate_order(params)
        params['orderValue'] &&
        params['orderCurrency'] &&
        params['externalDeliveryTypeId'] &&
        params['externalDeliveryTypeName'] &&
        params['externalPaymentTypeId'] &&
        params['externalPaymentTypeName'] &&
        params['externalCarrierId'] &&
        params['externalCarrierName'] &&
        params['externalCountryId'] &&
        params['externalBuyerId'] &&
        params['externalOrderId'] &&
        params['shipmentTemplate'] &&
        params['comments'] &&
        params['createdOn'] &&
        params['deliveryPrice'] &&
        params['deliveryPriceCurrency'] &&
        params['deliveryAddress'] &&
        params['deliveryAddress']['street'] &&
        params['deliveryAddress']['zipCode'] &&
        params['deliveryAddress']['city'] &&
        params['deliveryAddress']['countryAlpha2Code'] &&
        params['deliveryAddress']['firstName'] &&
        params['deliveryAddress']['lastName'] &&
        params['deliveryAddress']['companyName'] &&
        params['deliveryAddress']['phone'] &&
        params['deliveryAddress']['email']
      end
  end
end

require 'test_helper'

class SheeplaTest < ActiveSupport::TestCase
  test "data" do
    sample_data = {
      order_value: 299,
      order_value_currency: "PLN",
      external_delivery_type_id: "07",
      external_delivery_type_name: "DHL AH",
      external_payment_type_id: "pp",
      external_payment_type_name: "PayPal",
      external_carrier_id: "dhl02",
      external_carrier_name: "DHL Poland",
      external_country_id: "PL",
      external_buyer_id: "b123",
      external_order_id: "ah-200-abc",
      shipment_template: 122,
      comments: "Some info about delivery",
      created_on: DateTime.now,
      delivery_price: 12,
      delivery_price_currency: "PLN",
      delivery_address: {
        street: "Orba 1 Street",
        zip_code: "01-234",
        city: "Hel",
        country_alpha2_code: 1045,
        first_name: "Jean",
        last_name: "Kowalski",
        company_name: "LTD JK",
        phone: "963852741",
        email: "jean.kowalski@orba.pl"
      },
      order_items: [
        {
          name: "IPad",
          sku: "sku1",
          qty: "1",
          unit: "szt.",
          weight: "2",
          width: "1",
          height: "35",
          length: "20",
          volume: "0.001",
          priceGross: "2000",
          ean13: "1647984612122",
          issn: "9223372036854775807"
        }, {
          name: "Nokia L4",
          sku: "sku2",
          qty: "1",
          unit: "szt.",
          weight: "1.6",
          width: "1",
          height: "15",
          length: "10",
          volume: "0.001",
          priceGross: "1000",
          orderItemDiscountType: "orderItemDiscountType2",
          orderItemDiscountValue: "-79228162514264337593543950335",
          ean13: "7647984612122",
          issn: "9223372036854775807"
        }
      ]
    }
  end
end

# -*- coding: utf-8 -*-
require 'payex'
require 'spec_helper'
require 'savon/mock/spec_helper'

describe PayEx do
  include Savon::SpecHelper

  before(:all) { savon.mock!   }
  after(:all)  { savon.unmock! }

  describe :initialize! do
    example 'successful initialization' do
      expected = {
        'accountNumber' => PAYEX_ACCOUNT_NUMBER,
        'purchaseOperation' => 'AUTHORIZATION',
        'price' => SAMPLE_PRICE_CENTS,
        'priceArgList' => '',
        'currency' => PAYEX_DEFAULT_CURRENCY,
        'vat' => 0,
        'orderID' => SAMPLE_ORDER_ID,
        'productNumber' => SAMPLE_PRODUCT_NUMBER,
        'description' => SAMPLE_PRODUCT_DESCRIPTION,
        'clientIPAddress' => '12.34.56.78',
        'clientIdentifier' => '',
        'additionalValues' => 'RESPONSIVE=1',
        'externalID' => '',
        'returnUrl' => 'http://example.com/payex-return',
        'view' => 'CREDITCARD',
        'agreementRef' => '',
        'cancelUrl' => 'http://example.com/payex-cancel',
        'clientLanguage' => ''
      }
      expected['hash'] = PayEx::API.signed_hash(expected.values.join)

      initialize_ok_fixture = File.read('spec/fixtures/initialize8/initialize_ok.xml')
      savon.expects(:initialize8).with(message: expected).returns(initialize_ok_fixture)

      href = PayEx.initialize!(
        purchase_operation: expected.fetch('purchaseOperation'),
        price: expected.fetch('price'),
        order_id: expected.fetch('orderID'),
        product_number: expected.fetch('productNumber'),
        description: expected.fetch('description'),
        client_ip_address: expected.fetch('clientIPAddress'),
        return_url: expected.fetch('returnUrl'),
        cancel_url: expected.fetch('cancelUrl')
      )
      href.should include :order_ref
    end
  end
end

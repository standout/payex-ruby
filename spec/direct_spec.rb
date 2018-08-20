# -*- coding: utf-8 -*-
require 'payex'
require 'spec_helper'
require 'savon/mock/spec_helper'

describe PayEx::Direct do
  include Savon::SpecHelper

  before(:all) { savon.mock!   }
  after(:all)  { savon.unmock! }

  describe :purchase_invoice_private! do
    def invoke_purchase_invoice_private! response_fixture_file
      expected = {
        'accountNumber' => PAYEX_ACCOUNT_NUMBER,
        'orderRef' => SAMPLE_ORDER_REF,
        'customerRef' => '1000',
        'customerName' => 'John Doe',
        'streetAddress' => 'Test',
        'coAddress' => '',
        'postalCode' => '12345',
        'city' => 'Test',
        'country' => 'SE',
        'socialSecurityNumber' => '197610277373',
        'phoneNumber' => '0733123456',
        'email' => 'test@example.com',
        'productCode' => SAMPLE_PRODUCT_CODE,
        'creditcheckRef' => '',
        'mediaDistribution' => 1,
        'invoiceText' => 'Test',
        'invoiceDate' => '2017-10-27',
        'invoiceDueDays' => 14,
        'invoiceNumber' => 1000,
        'invoiceLayout' => ''
      }

      expected['hash'] = PayEx::API.signed_hash(expected.values.join)
      response_fixture = File.read("spec/fixtures/purchase_invoice_private/#{response_fixture_file}.xml")
      savon.expects(:purchase_invoice_private).with(message: expected).returns(response_fixture)
      PayEx::Direct.purchase_invoice_private!(
        order_ref: expected.fetch('orderRef'),
        customer_ref: expected.fetch('customerRef'),
        customer_name: expected.fetch('customerName'),
        street_address: expected.fetch('streetAddress'),
        co_address: expected.fetch('coAddress'),
        postal_code: expected.fetch('postalCode'),
        city: expected.fetch('city'),
        country: expected.fetch('country'),
        social_security_number: expected.fetch('socialSecurityNumber'),
        phone_number: expected.fetch('phoneNumber'),
        email: expected.fetch('email'),
        product_code: expected.fetch('productCode'),
        creditcheck_ref: expected.fetch('creditcheckRef'),
        media_distribution: expected.fetch('mediaDistribution'),
        invoice_text: expected.fetch('invoiceText'),
        invoice_date: expected.fetch('invoiceDate'),
        invoice_due_days: expected.fetch('invoiceDueDays'),
        invoice_number: expected.fetch('invoiceNumber'),
        invoice_layout: expected.fetch('invoiceLayout')
      )
    end

    example 'successful purchase' do
      order_id, error, data = invoke_purchase_invoice_private! :purchase_invoice_private_ok
      order_id.should == SAMPLE_ORDER_ID
      error.should == nil
    end

    example 'unexpected failure' do
      order_id, error, data = invoke_purchase_invoice_private! :purchase_invoice_private_failed
      order_id.should == SAMPLE_ORDER_ID
      error.should be_a PayEx::Error
    end
  end
end

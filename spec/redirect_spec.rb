# -*- coding: utf-8 -*-
require 'payex'
require 'spec_helper'
require 'savon/mock/spec_helper'

describe PayEx::Redirect do
  include Savon::SpecHelper

  before(:all) { savon.mock!   }
  after(:all)  { savon.unmock! }

  describe :complete! do
    def invoke_complete! response_fixture_file
      expected = {
        'accountNumber' => PAYEX_ACCOUNT_NUMBER,
        'orderRef' => SAMPLE_ORDER_REF
      }

      expected['hash'] = PayEx::API.signed_hash(expected.values.join)
      response_fixture = File.read("spec/fixtures/complete/#{response_fixture_file}.xml")
      savon.expects(:complete).with(message: expected).returns(response_fixture)
      PayEx::Redirect.complete!(expected.fetch('orderRef'))
    end

    example 'successful completion' do
      order_id, error, data = invoke_complete! :complete_ok
      order_id.should == SAMPLE_ORDER_ID
      error.should == nil
    end

    example 'unexpected failure' do
      order_id, error, data = invoke_complete! :complete_failed
      order_id.should == SAMPLE_ORDER_ID
      error.should be_a PayEx::Error
    end

    example 'card declined' do
      order_id, error, data = invoke_complete! :complete_declined
      order_id.should == SAMPLE_ORDER_ID
      error.should be_a PayEx::Error
      error.should be_a PayEx::Error::CardDeclined
    end
  end
end

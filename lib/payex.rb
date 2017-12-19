module PayEx
  extend self

  TEST_URL = 'https://external.externaltest.payex.com'
  LIVE_URL = 'https://external.payex.com'

  attr_accessor :base_url

  self.base_url = PayEx::TEST_URL

  attr_accessor :account_number
  attr_accessor :encryption_key
  attr_accessor :default_currency

  def initialize!(params)
    PayEx::PxOrder.Initialize8(
      accountNumber: params[:account_number],
      purchaseOperation: params[:purchase_operation],
      price: params[:price],
      priceArgList: params[:price_arg_list],
      currency: params[:currency],
      vat: params[:vat],
      orderID: params[:order_id],
      productNumber: params[:product_number],
      description: params[:description],
      clientIPAddress: params[:client_ip_address],
      clientIdentifier: params[:client_identifier],
      additionalValues: params[:additional_values],
      externalID: params[:external_id],
      returnUrl: params[:return_url],
      view: params[:view],
      agreementRef: params[:agreement_ref],
      cancelUrl: params[:cancel_url],
      clientLanguage: params[:client_language]
    )
  end

  def create_agreement!(params)
    response = PayEx::PxAgreement.CreateAgreement3(
      accountNumber: params[:account_number],
      description: params[:description],
      purchaseOperation: params[:purchase_operation],
      maxAmount: params[:max_amount],
      notifyUrl: params[:notify_url],
      startDate: params[:start_date],
      stopDate: params[:stop_date],
      merchantRef: params[:merchant_ref],
    )
    error_code = response[:status][:error_code]
    if error_code == 'OK'
      error = nil
    else
      error = PayEx::Error.new "Agreement failed: #{error_code}"
    end
    [response[:agreement_ref], error]
  end

  def delete_agreement!(params)
    response = PayEx::PxAgreement.DeleteAgreement(
      accountNumber: params[:account_number],
      agreementRef: params[:agreement_ref]
    )
  end

  def check!(params)
    response = PayEx::PxAgreement.Check(
      accountNumber: params[:account_number],
      agreementRef: params[:agreement_ref]
    )

    error_code = response[:status][:error_code]
    if error_code == 'OK'
      error = nil
    else
      error = PayEx::Error.new "Agreement failed: #{error_code}"
    end
    [response[:agreement_status], error, response]
  end

  def auto_pay!(params)
    response = PayEx::PxAgreement.AutoPay3(
      accountNumber: params[:account_number],
      agreementRef: params[:agreement_ref],
      price: params[:price],
      productNumber: params[:product_number],
      description: params[:description],
      orderId: params[:order_id],
      purchaseOperation: params[:purchase_operation],
      currency: params[:currency]
    )
    status = response[:transaction_status]
    status = PayEx::API.parse_transaction_status(status)

    case status
    when :sale, :authorize
      error = nil
    else
      error = PayEx::Error.new('Transaction failed')
    end

    [response[:order_id], error, response]
  end

  def account_number!
    account_number or fail 'Please set PayEx.account_number'
  end

  def encryption_key!
    encryption_key or fail 'Please set PayEx.encryption_key'
  end

  def default_currency!
    default_currency or fail 'Please set PayEx.default_currency'
  end
end

class PayEx::Error < StandardError; end
class PayEx::Error::CardDeclined < PayEx::Error; end

require 'payex/api'
require 'payex/api/pxorder'
require 'payex/api/pxagreement'
require 'payex/direct'
require 'payex/redirect'

module PayEx::PxAgreement
  extend self

  def wsdl
    '%s/pxagreement/pxagreement.asmx?WSDL' % PayEx.base_url
  end

  def CreateAgreement3(params)
    PayEx::API.invoke! wsdl, :create_agreement3, params, {
      'accountNumber' => {
        signed: true,
        default: proc { PayEx.account_number! }
      },
      'merchantRef' => {
        signed: true,
        default: ''
      },
      'description' => {
        signed: true,
        format: /^.{,160}$/
      },
      'purchaseOperation' => {
        signed: true,
        default: 'SALE'
      },
      'maxAmount' => {
        signed: true,
        default: '1000000'
      },
      'notifyUrl' => {
        signed: true,
        default: ''
      },
      'startDate' => {
        signed: true,
        default: ''
      },
      'stopDate' => {
        signed: true,
        default: ''
      }
    }
  end

  def DeleteAgreement(params)
    PayEx::API.invoke! wsdl, :delete_agreement, params, {
      'accountNumber' => {
        signed: true,
        default: proc { PayEx.account_number! }
      },
      'agreementRef' => {
        signed: true,
        default: ''
      }
    }
  end

  def Check(params)
    PayEx::API.invoke! wsdl, :check, params, {
      'accountNumber' => {
        signed: true,
        default: proc { PayEx.account_number! }
      },
      'agreementRef' => {
        signed: true,
        default: ''
      }
    }
  end

  def AutoPay3(params)
    PayEx::API.invoke! wsdl, :auto_pay3, params, {
      'accountNumber' => {
        signed: true,
        default: proc { PayEx.account_number! }
      },
      'agreementRef' => {
        signed: true,
        default: ''
      },
      'price' => {
        signed: true
      },
      'productNumber' => {
        signed: true,
        default: ''
      },
      'description' => {
        signed: true,
        format: /^.{,160}$/
      },
      'orderId' => {
        signed: true,
        default: ''
      },
      'purchaseOperation' => {
        signed: true,
        default: 'SALE'
      },
      'currency' => {
        signed: true,
        default: ''
      }
    }
  end
end
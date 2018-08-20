module PayEx::PxOrder
  extend self

  def wsdl
    '%s/pxorder/pxorder.asmx?WSDL' % PayEx.base_url
  end

  def Initialize8(params)
    PayEx::API.invoke! wsdl, :initialize8, params, {
      'accountNumber' => {
        signed: true,
        default: proc { PayEx.account_number! }
      },
      'purchaseOperation' => {
        signed: true,
        default: 'SALE'
      },
      'price' => {
        signed: true,
        format: Integer
      },
      'priceArgList' => {
        signed: true,
        default: ''
      },
      'currency' => {
        signed: true,
        default: proc { PayEx.default_currency! }
      },
      'vat' => {
        signed: true,
        format: Integer,
        default: 0
      },
      'orderID' => {
        signed: true,
        format: /^[a-z0-9]{,50}$/i
      },
      'productNumber' => {
        signed: true,
        format: /^[A-Z0-9]{,50}$/
      },
      'description' => {
        signed: true,
        format: /^.{,160}$/
      },
      'clientIPAddress' => {
        signed: true
      },
      'clientIdentifier' => {
        signed: true,
        default: ''
      },
      'additionalValues' => {
        signed: true,
        default: 'RESPONSIVE=1'
      },
      'externalID' => {
        signed: true,
        default: ''
      },
      'returnUrl' => {
        signed: true
      },
      'view' => {
        signed: true,
        default: 'CREDITCARD'
      },
      'agreementRef' => {
        signed: true,
        default: ''
      },
      'cancelUrl' => {
        signed: true,
        default: ''
      },
      'clientLanguage' => {
        signed: true,
        default: ''
      }
    }
  end

  def Complete(params)
    PayEx::API.invoke! wsdl, :complete, params, {
      'accountNumber' => {
        signed: true,
        default: proc { PayEx.account_number! }
      },
      'orderRef' => {
        signed: true
      }
    }
  end

  def PurchaseInvoicePrivate(params)
    PayEx::API.invoke! wsdl, :purchase_invoice_private, params, {
      'accountNumber' => {
        signed: true,
        default: -> { PayEx.account_number! }
      },
      'orderRef' => {
        signed: true
      },
      'customerRef' => {
        signed: true,
        format: /\A[a-zA-Z0-9]{,15}\z/
      },
      'customerName' => {
        signed: true,
        format: /\A[a-zA-Z0-9_:!;\"#<>=?\\[\\]@{}´\n\r %-\/À-ÖØ-öø-úü]{,35}\z/,
        resolve: -> (v) { v[0..34].strip }
      },
      'streetAddress' => {
        signed: true,
        format: /\A[a-zA-Z0-9_:!;\"#<>=?\\[\\]@{}´\n\r %-\/À-ÖØ-öø-úü]{,35}\z/
      },
      'coAddress' => {
        signed: true,
        format: /\A[a-zA-Z0-9_:!;\"#<>=?\\[\\]@{}´\n\r %-\/À-ÖØ-öø-úü]{,35}\z/
      },
      'postalCode' => {
        signed: true,
        format: /[A-Z0-9\-]{,9}/
      },
      'city' => {
        signed: true,
        format: /\A[a-zA-Z0-9_:!;\"#<>=?\\[\\]@{}´\n\r %-\/À-ÖØ-öø-úü]{,27}\z/
      },
      'country' => {
        signed: true,
        format: /\A[A-Z]{,2}\z/
      },
      'socialSecurityNumber' => {
        signed: true,
        format: /\A[a-zA-Z0-9_:!;\"#<>=?\\[\\]@{}´\n\r %-\/À-ÖØ-öø-úü]{,15}\z/
      },
      'phoneNumber' => {
        signed: true,
        format: /\A[a-zA-Z0-9_:!;\"#<>=?\\[\\]@{}´\n\r %-\/À-ÖØ-öø-úü]{,15}\z/,
        resolve: -> (v) { v[0..14].strip }
      },
      'email' => {
        signed: true,
        format: /\A.{,60}\z/
      },
      'productCode' => {
        signed: true,
        default: '',
        format: /\A[a-zA-Z0-9_:!;\"#<>=?\\[\\]@{}´\n\r %-\/À-ÖØ-öø-úü]{,5}\z/
      },
      'creditcheckRef' => {
        signed: true,
        default: '',
        format: /\A.{,32}\z/
      },
      'mediaDistribution' => {
        signed: true,
        format: Integer
      },
      'invoiceText' => {
        signed: true,
        format: /\A.{,50}\z/
      },
      'invoiceDate' => {
        signed: true,
        default: Time.now.strftime('%Y-%m-%d'),
        format: /\A\d{4}-\d{2}-\d{2}\z/
      },
      'invoiceDueDays' => {
        signed: true,
        default: 14,
        format: Integer
      },
      'invoiceNumber' => {
        signed: true,
        format: Integer
      },
      'invoiceLayout' => {
        signed: true,
        default: '',
        format: /\A.{,3960}\z/
      }
    }
  end
end

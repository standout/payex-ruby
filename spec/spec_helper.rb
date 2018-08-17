# Suppress "HTTPI executes HTTP GET using the httpclient adapter"
HTTPI.log = false

PAYEX_ACCOUNT_NUMBER = 'ACCOUNTNUMBER1000'
PAYEX_ENCRYPTION_KEY = 'ENCRYPTIONKEY1000'
PAYEX_DEFAULT_CURRENCY = 'SEK'

SAMPLE_ORDER_REF = 'ORDERREF1000'
SAMPLE_ORDER_ID = 'ORDERID1000'
SAMPLE_PRODUCT_NUMBER = 'PRODUCTNUMBER1000'
SAMPLE_PRODUCT_CODE = '10000'
SAMPLE_PRODUCT_DESCRIPTION = 'Sample product description'
SAMPLE_PRICE_CENTS = 12300

RSpec.configure do |config|
  config.before(:each) do
    PayEx.account_number = PAYEX_ACCOUNT_NUMBER
    PayEx.encryption_key = PAYEX_ENCRYPTION_KEY
    PayEx.default_currency = PAYEX_DEFAULT_CURRENCY
  end
end

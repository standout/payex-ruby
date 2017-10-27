module PayEx::Direct
  extend self

  def purchase_invoice_private!(params)
    response = PayEx::PxOrder.PurchaseInvoicePrivate(
      accountNumber: params[:account_number],
      orderRef: params[:order_ref],
      customerRef: params[:customer_ref],
      customerName: params[:customer_name],
      streetAddress: params[:street_address],
      coAddress: params[:co_address],
      postalCode: params[:postal_code],
      city: params[:city],
      country: params[:country],
      socialSecurityNumber: params[:social_security_number],
      phoneNumber: params[:phone_number],
      email: params[:email],
      productCode: params[:product_code],
      creditcheckRef: params[:creditcheck_ref],
      mediaDistribution: params[:media_distribution],
      invoiceText: params[:invoice_text],
      invoiceDate: params[:invoice_date],
      invoiceDueDays: params[:invoice_due_days],
      invoiceNumber: params[:invoice_number],
      invoiceLayout: params[:invoice_layout]
    )

    status = response[:transaction_status]
    status = PayEx::API.parse_transaction_status(status)

    case status
    when :sale, :authorize
      error = nil
    when :initialize
      error = PayEx::Error.new('Transaction not completed')
    else
      error = PayEx::Error.new('Transaction failed')
    end

    [response[:order_id], error, response]
  end
end

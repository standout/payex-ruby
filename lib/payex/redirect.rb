module PayEx::Redirect
  extend self

  def complete!(id)
    response = PayEx::PxOrder.Complete(orderRef: id)

    status = response[:transaction_status]
    status = PayEx::API.parse_transaction_status(status)

    case status
    when :sale, :authorize
      error = nil
    when :initialize
      error = PayEx::Error.new('Transaction not completed')
    when :failure
      details = response[:error_details].inspect
      case details
      when /declined/i
        error = PayEx::Error::CardDeclined.new('Card declined')
      else
        error = PayEx::Error.new('Transaction failed')
      end
    else
      error = PayEx::Error.new('Transaction failed')
    end

    [response[:order_id], error, response]
  end
end

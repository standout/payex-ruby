require 'nori'
require 'savon'

module PayEx::API
  extend self

  class ParamError < StandardError; end

  def invoke! wsdl, name, params, specs
    body = get_request_body(params, specs)
    response = invoke_raw! wsdl, name, body

    # Unwrap e.g. <Initialize8Response>
    response = response[response.keys.first]
    # Unwrap e.g. <Initialize8Result>
    response = response[response.keys.first]
    # Parse embedded XML document
    parser = Nori.new(convert_tags_to: lambda { |tag| tag.snakecase.to_sym })
    response = parser.parse(response)
    # Unwrap <payex>
    response = response[response.keys.first]

    if ok = response[:status][:code] == 'OK' rescue false
      response
    elsif defined? response[:status][:description]
      raise PayEx::Error, response[:status][:description]
    else
      raise PayEx::Error, %{invalid response: #{response.inspect}}
    end
  end

  def invoke_raw! wsdl, name, body
    Savon.client(wsdl: wsdl).call(name, soap_action: false, message: body).body
  end

  def signed_hash(string)
    Digest::MD5.hexdigest(string + PayEx.encryption_key!)
  end

  def get_request_body(params, specs)
    parse_params(params, specs).tap do |params|
      params['hash'] = sign_params(params, specs)
    end
  end

  def sign_params(params, specs)
    signed_hash(hashed_params(params, specs).join)
  end

  def hashed_params(params, specs)
    specs.select { |key, options| options[:signed] }.
      keys.map { |key| params[key] }
  end

  def parse_params(params, specs)
    stringify_keys(params).tap do |result|
      _parse_params! result, specs
      result.select! { |k, v| v != nil }
    end
  end

  def stringify_keys(hash)
    Hash[*hash.map { |k, v| [k.to_s, v] }.flatten]
  end

  def _parse_params!(params, specs)
    for name, options in specs
      begin
        params[name] = parse_param(params[name], options)
      rescue PayEx::API::ParamError => error
        param_error! %{#{name.inspect}: #{error.message}}
      end
    end
  end

  def parse_param(param, options)
    value = param || options.fetch(:default) { param_error! 'parameter required' }
    value = value.call if value.respond_to?(:call)

    return value if valid_param_format?(value, options)

    if resolver?(options[:resolve])
      resolver = options[:resolve]
      parse_param(resolver.call(value), except(options, :default, :resolve))
    else
      param_error! %(must match #{options[:format].inspect})
    end
  end

  def except(options, *keys)
    options.dup.tap { |o| keys.each { |k| o.delete(k) } }
  end

  def resolver?(resolver)
    resolver.respond_to?(:call)
  end

  def param_error! message
    raise ParamError, message
  end

  def parse_transaction_status(status)
    case status.to_s
    when '0' then :sale
    when '1' then :initialize
    when '2' then :credit
    when '3' then :authorize
    when '4' then :cancel
    when '5' then :failure
    when '6' then :capture
    else status.to_s
    end
  end

  def valid_param_format?(param, options)
    !options.include?(:format) || options[:format] === param
  end
end

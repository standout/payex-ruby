# -*- coding: utf-8 -*-
require 'payex'
require 'spec_helper'

describe PayEx::API do
  before {
    PayEx.encryption_key = 'foo'
  }

  it 'should know how to stringify keys' do
    PayEx::API.stringify_keys(a: 1, b: 2).
      should == { 'a' => 1, 'b' => 2 }
  end

  it 'should know how to sign params' do
    param_hash, specs, param_array = {}, {}, []

    for name in 'a'..'z'
      if rand < 0.5
        param_hash[name] = rand
        param_array << param_hash[name]
        specs[name] = { signed: true }
      else
        param_hash[name] = rand
      end
    end

    actual = PayEx::API.sign_params(param_hash, specs)

    to_sign = param_array.join + PayEx.encryption_key
    expected = Digest::MD5.hexdigest(to_sign)

    actual.should == expected
  end

  it 'should know how to add defaults' do
    PayEx::API.parse_param(nil, { default: 2 }).should == 2
  end

  it 'should know how to call default procs' do
    PayEx::API.parse_param(nil, { default: proc { 2 } }).should == 2
  end

  it 'should reject wrong type of value' do
    proc {
      PayEx::API.parse_param('foobar', { format: Integer })
    }.should raise_error PayEx::API::ParamError
  end

  it 'should reject strings based on regular expressions' do
    proc {
      PayEx::API.parse_param('foobar', { format: /^.{,3}$/ })
    }.should raise_error PayEx::API::ParamError
  end

  it 'should stringify keys when parsing params' do
    PayEx::API.parse_params({ a: 1 }, { 'b' => { default: 2 } }).
      should == { 'a' => 1, 'b' => 2 }
  end

  describe '#parse_param' do
    context 'when format validation fails' do
      context 'when resolve proc is present' do
        it 'calls the proc' do
          resolver = -> (v) { v[0..2].strip }

          options = { format: /^[a-z]{,3}$/, resolve: resolver }

          resolver.should_receive(:call).with('too long param').and_return('too')

          PayEx::API.parse_param('too long param', options)
        end

        context 'when validation still fails after the proc has been called' do
          it 'raises a ParamError' do
            resolver = -> (v) { v[0..2].strip }

            options = { format: /^[0-9]{,3}$/, resolve: resolver }

            result = -> { PayEx::API.parse_param('too long param', options) }

            result.should
              raise_error PayEx::API::ParamError, 'must match /^[0-9]{,3}$/'
          end
        end
      end
    end

    context 'when resolve is not present' do
      it 'raises a ParamError' do
        result = -> {
          PayEx::API.parse_param(
            'too long param',
            { format: /^[a-z]{,3}$/ }
          )
        }

        result.should
          raise_error PayEx::API::ParamError, 'must match /^[a-z]{,3}$/'
      end
    end
  end

  describe '#resolver?' do
    context 'when resolver respond to call' do
      it 'returns true' do
        resolver = -> { 'value' }

        PayEx::API.resolver?(resolver).should == true
      end
    end

    context 'when resolver does not respond to call' do
      it 'returns false' do
        resolver = 'value'

        PayEx::API.resolver?(resolver).should == false
      end
    end
  end

  describe '#valid_param_format?' do
    context 'when param format is valid' do
      it 'returns true' do
        options = { format: /^[a-z]{,3}$/ }
        param = 'abc'

        PayEx::API.valid_param_format?(param, options).should == true
      end
    end

    context 'when param format is invalid' do
      it 'returns false' do
        options = { format: /^[a-z]{,3}$/ }
        param = 123

        PayEx::API.valid_param_format?(param, options).should == false
      end
    end
  end
end

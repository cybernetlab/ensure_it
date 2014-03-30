require 'spec_helper'

class Tester
  using EnsureIt if ENSURE_IT_REFINED

  def ensure_string(*args)
    obj.ensure_string(*args)
  end

  def ensure_string!(*args)
    obj.ensure_string!(*args)
  end
end

describe EnsureIt do
  shared_examples 'stringifier' do
    it 'and returns self for string' do
      obj = 'test'
      expect(call_for(obj)).to eq obj
    end

    it 'and converts symbols to string' do
      expect(call_for(:test)).to eq 'test'
    end

    it 'and converts numbers to string with :numbers option' do
      expect(call_for(100, numbers: true)).to eq '100'
      expect(call_for(0.5, numbers: true)).to eq '0.5'
      expect(call_for(Rational(2, 3), numbers: true)).to eq '2/3'
    end

    it 'and downcases value with downcase option' do
      expect(call_for(:teST, downcase: true)).to eq 'test'
      expect(call_for('teST', downcase: true)).to eq 'test'
    end
  end

  describe '#ensure_string' do
    it_behaves_like 'stringifier'
    it_behaves_like 'niller for unmet objects', except: [String, Symbol]
    it_behaves_like 'values checker', :one, :test, values: %w(one two)
    it_behaves_like 'values checker', 'one', 'test', values: %w(one two)
  end

  describe '#ensure_string!' do
    it_behaves_like 'stringifier'
    it_behaves_like(
      'banger for unmet objects',
      except: [String, Symbol],
      message: /should be a String or a Symbol/
    )

    it 'raises correct error message with :numbers option' do
      expect { call_for(nil, numbers: true) }.to raise_error(
        EnsureIt::Error,
        /should be a String, Symbol, Numeric or Rational/
      )
    end
  end
end

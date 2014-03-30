require 'spec_helper'

class Tester
  using EnsureIt if ENSURE_IT_REFINED

  def ensure_symbol(*args)
    obj.ensure_symbol(*args)
  end

  def ensure_symbol!(*args)
    obj.ensure_symbol!(*args)
  end
end

describe EnsureIt do
  shared_examples 'symbolizer' do
    it 'and returns self for symbol' do
      expect(call_for(:test)).to eq :test
    end

    it 'and converts string to symbol' do
      expect(call_for('test')).to eq :test
    end

    it 'and returns symbol if it in values' do
      expect(call_for(:test, values: %i(test me))).to eq :test
      expect(call_for('me', values: %i(test me))).to eq :me
    end

    it 'and downcases value with downcase option' do
      expect(call_for(:teST, downcase: true)).to eq :test
      expect(call_for('teST', downcase: true)).to eq :test
    end
  end

  describe '#ensure_symbol' do
    it_behaves_like 'symbolizer'
    it_behaves_like 'niller for unmet objects', except: [String, Symbol]
    it_behaves_like 'values checker', :one, :test, values: %i(one two)
    it_behaves_like 'values checker', 'one', 'test', values: %i(one two)

    it 'returns nil if value not in values option' do
      expect(call_for(:val, values: %i(test me))).to be_nil
    end
  end

  describe '#ensure_symbol!' do
    it_behaves_like 'symbolizer'
    it_behaves_like(
      'banger for unmet objects',
      except: [String, Symbol],
      message: /should be a Symbol or a String/
    )

    it 'raises error if value not in values option' do
      expect {
        call_for(:val, values: %i(test me))
      }.to raise_error EnsureIt::Error
    end
  end
end

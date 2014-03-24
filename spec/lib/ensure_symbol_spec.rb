require 'spec_helper'

class Tester
  using EnsureIt if ENSURE_IT_REFINES

  def ensure_symbol(*args)
    obj.ensure_symbol(*args)
  end

  def ensure_symbol!(*args)
    obj.ensure_symbol!(*args)
  end
end

describe EnsureIt do
  shared_examples 'symbolizer' do
    it 'returns self for symbol' do
      expect(call_for(:test)).to eq :test
    end

    it 'converts string to symbol' do
      expect(call_for('test')).to eq :test
    end
  end

  describe '#ensure_symbol' do
    it_behaves_like 'symbolizer'
    it_behaves_like 'niller for unmet objects', String, Symbol
  end

  describe '#ensure_symbol!' do
    it_behaves_like 'symbolizer'
    it_behaves_like(
      'banger for unmet objects',
      String, Symbol,
      message: /should be a Symbol or a String/
    )
  end
end

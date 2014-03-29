require 'spec_helper'

class Tester
  using EnsureIt if ENSURE_IT_REFINED

  def ensure_float(*args)
    obj.ensure_float(*args)
  end

  def ensure_float!(*args)
    obj.ensure_float!(*args)
  end
end

describe EnsureIt do
  shared_examples 'float numerizer' do
    it 'and returns self for Float' do
      obj = 0.1
      expect(call_for(obj)).to eq obj
    end

    it 'and converts Rational' do
      expect(call_for(Rational(1, 2))).to eq 0.5
    end

    it 'and converts Integers' do
      expect(call_for(100)).to eq 100.0
      expect(call_for(100)).to be_kind_of(Float)
    end

    it 'and converts decimal strings' do
      expect(call_for('100')).to eq(100.0)
      expect(call_for('100')).to be_kind_of(Float)
    end

    it 'and converts strings with dot' do
      expect(call_for('0.1')).to eq(0.1)
    end

    it 'and converts scientific strings' do
      expect(call_for('1e3')).to eq(1000.0)
      expect(call_for('1e-3')).to eq(0.001)
      expect(call_for('-1.5e+3')).to eq(-1500.0)
    end
  end

  describe '#ensure_float' do
    it_behaves_like 'float numerizer'
    it_behaves_like(
      'niller for unmet objects',
      '123test', :test123, :'0.1',
      except: [String, Integer, Float, Rational]
    )
    it_behaves_like 'values checker', 10.0, 23.5, values: [10.0, 11.0, 12.0]
    it_behaves_like 'values checker', 10, 23, values: [10.0, 11.0, 12.0]
  end

  describe '#ensure_float!' do
    it_behaves_like 'float numerizer'
    it_behaves_like(
      'banger for unmet objects',
      '123test', :test123, :'0.1',
      except: [String, Integer, Float, Rational],
      message: /should be a float or be able to convert to it/
    )
  end
end

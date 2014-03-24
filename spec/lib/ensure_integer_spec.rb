require 'spec_helper'

class Tester
  using EnsureIt if ENSURE_IT_REFINES

  def ensure_integer(*args)
    obj.ensure_integer(*args)
  end

  def ensure_integer!(*args)
    obj.ensure_integer!(*args)
  end
end

describe EnsureIt do
  shared_examples 'numerizer' do
    it 'and returns self for Fixnum' do
      obj = 1000
      expect(call_for(obj)).to eq obj
    end

    it 'and returns self for Bignum' do
      obj = BIGNUM
      expect(call_for(obj)).to eq obj
    end

    it 'and converts strings' do
      expect(call_for('-100')).to eq(-100)
    end

    it 'and converts symbols' do
      expect(call_for(:'100')).to eq(100)
    end

    it 'and rounds floats' do
      expect(call_for(10.1)).to eq(10)
      expect(call_for(10.5)).to eq(11)
    end

    it 'and converts rationales' do
      expect(call_for(Rational(5, 2).to_r)).to eq(3)
    end

    it 'and converts boolean with :boolean option' do
      expect(call_for(true, boolean: true)).to eq 1
      expect(call_for(false, boolean: true)).to eq 0
    end

    it 'and converts boolean with numeric :boolean option' do
      expect(call_for(true, boolean: 100)).to eq 100
      expect(call_for(false, boolean: 100)).to eq 0
    end
  end

  describe '#ensure_integer' do
    it_behaves_like 'numerizer'
    it_behaves_like(
      'niller for unmet objects',
      '123test', :test123,
      except: [String, Symbol, Integer, Float, Rational]
    )
  end

  describe '#ensure_integer!' do
    it_behaves_like 'numerizer'
    it_behaves_like(
      'banger for unmet objects',
      '123test', :test123,
      except: [String, Symbol, Integer, Float, Rational],
      message: /should be an integer or be able to convert to it/
    )
  end
end

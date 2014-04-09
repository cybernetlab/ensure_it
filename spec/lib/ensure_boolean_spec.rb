require 'spec_helper'

class Tester
  using EnsureIt if ENSURE_IT_REFINED

  def ensure_boolean(*args)
    obj.ensure_boolean(*args)
  end

  def ensure_boolean!(*args)
    obj.ensure_boolean!(*args)
  end
end

describe EnsureIt do
  shared_examples 'polygraph' do
    it 'and returns self for TrueClass' do
      obj = true
      expect(call_for(obj)).to eq obj
    end

    it 'and returns self for FalseClass' do
      obj = false
      expect(call_for(obj)).to eq obj
    end

    it 'and converts numbers' do
      expect(call_for(0)).to be_false
      expect(call_for(1)).to be_true
      expect(call_for(-1.0)).to be_true
    end

    it 'and converts numbers with positive: true' do
      expect(call_for(1, positive: true)).to be_true
      expect(call_for(-1, positive: true)).to be_false
    end

    it 'and converts strings with strings: true' do
      expect(call_for('true', strings: true)).to be_true
      expect(call_for('yes', strings: true)).to be_true
      expect(call_for('y', strings: true)).to be_true
      expect(call_for('1', strings: true)).to be_true
      expect(call_for('false', strings: true)).to be_false
    end

    it 'and converts symbols with strings: true' do
      expect(call_for(:true, strings: true)).to be_true
      expect(call_for(:yes, strings: true)).to be_true
      expect(call_for(:y, strings: true)).to be_true
      expect(call_for(:'1', strings: true)).to be_true
      expect(call_for(:false, strings: true)).to be_false
    end
  end

  describe '#ensure_boolean' do
    it_behaves_like 'polygraph'
    it_behaves_like(
      'niller for unmet objects',
      '123test', :test123, :'100',
      except: [Numeric, TrueClass, FalseClass]
    )
  end

  describe '#ensure_boolean!' do
    it_behaves_like 'polygraph'
    it_behaves_like(
      'banger for unmet objects',
      '123test', :test123, :'100',
      except: [Numeric, TrueClass, FalseClass],
      message: /should be a boolean or be able to convert to it/
    )
  end
end

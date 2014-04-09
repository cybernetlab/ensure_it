require 'spec_helper'

class Tester
  using EnsureIt if ENSURE_IT_REFINED

  def ensure_class(*args)
    obj.ensure_class(*args)
  end

  def ensure_class!(*args)
    obj.ensure_class!(*args)
  end
end

describe EnsureIt do
  shared_examples 'class selector' do
    it 'and returns self for right classes' do
      expect(call_for(String)).to eq String
    end

    it 'and checks for ancestors' do
      expect(call_for(Array, Enumerable, Array)).to eq Array
    end

    it 'and converts string to class with strings option' do
      expect(call_for('Array', strings: true)).to eq Array
    end
  end

  describe '#ensure_class' do
    it_behaves_like 'class selector'
    it_behaves_like 'values checker', Array, Integer, values: [Array]

    it 'returns nil for wrong classes' do
      expect(call_for(10)).to be_nil
      expect(call_for(Float, Integer)).to be_nil
    end

    it 'returns default option for wrong classs' do
      expect(call_for(10, default: true)).to be_true
    end
  end

  describe '#ensure_class!' do
    it_behaves_like 'class selector'

    it 'raises for non-classes' do
      expect {
        call_for(10)
      }.to raise_error EnsureIt::Error, /should be a class\z/
    end

    it 'raises on wrong classes' do
      expect {
        call_for(Float, Integer)
      }.to raise_error EnsureIt::Error, /should subclass or extend all of/
    end
  end
end

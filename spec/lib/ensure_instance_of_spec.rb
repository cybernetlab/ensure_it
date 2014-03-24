require 'spec_helper'

class Tester
  using EnsureIt if ENSURE_IT_REFINES

  def ensure_instance_of(*args)
    obj.ensure_instance_of(*args)
  end

  def ensure_instance_of!(*args)
    obj.ensure_instance_of!(*args)
  end
end

describe EnsureIt do
  shared_examples 'instance selector' do
    it 'and returns self for right instances' do
      expect(call_for(:test, Symbol)).to eq :test
      expect(call_for('test', String)).to eq 'test'
    end

    it 'and raises ArgumentError for wrong class' do
      expect { call_for(:test, 1) }.to raise_error ArgumentError
    end
  end

  describe '#ensure_instance_of' do
    it_behaves_like 'instance selector'

    it 'returns nil for wrong instances' do
      expect(call_for(:test, String)).to be_nil
      expect(call_for('test', Symbol)).to be_nil
    end

    it 'returns wrong option for wrong instances' do
      expect(call_for(:test, String, wrong: 1)).to eq 1
    end
  end

  describe '#ensure_instance_of!' do
    it_behaves_like 'instance selector'

    it 'raises on wrong instances and classes' do
      expect {
        call_for(:test, String)
      }.to raise_error EnsureIt::Error, /should be an instance of .* class/
    end
  end
end

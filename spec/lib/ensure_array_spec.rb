require 'spec_helper'

class Tester
  using EnsureIt if ENSURE_IT_REFINED

  def ensure_array(*args)
    obj.ensure_array(*args)
  end

  def ensure_array!(*args)
    obj.ensure_array!(*args)
  end
end

describe EnsureIt do
  shared_examples 'array parser' do
    it 'and returns self for array' do
      obj = [1, nil, 2]
      expect(call_for(obj)).to eq obj
    end

    it 'compacts array with compact argument' do
      expect(call_for([1, nil, 2], :compact)).to eq [1, 2]
    end

    it 'flattens array with flatten argument' do
      expect(call_for([1, [2, 3], 4], :flatten)).to eq [1, 2, 3, 4]
    end

    it 'flattens and then sorts array with flatten and sort arguments' do
      expect(
        call_for([1, [5, 6], 4], :flatten, :sort)
      ).to eq [1, 4, 5, 6]
    end

    it 'sorts descending with sort_desc argument' do
      expect(call_for([1, 5, 6, 4], :sort_desc)).to eq [6, 5, 4, 1]
    end

    it 'calls :ensure_* for each element' do
      arr = ['s', nil, :v]
      expect(call_for(arr, :ensure_symbol, :compact)).to eq [:s, :v]
    end

    it 'calls standard method for each element' do
      arr = ['s', :v]
      expect(call_for(arr, :to_s)).to eq ['s', 'v']
    end

    it 'chains methods for each element' do
      arr = ['s', :v]
      expect(call_for(arr, :ensure_string, :to_sym)).to eq [:s, :v]
    end

    it 'selects only values, specified in values option' do
      expect(
        call_for([1, 5, 6, 4], values: [1, 6, 8])
      ).to eq [1, 6]
    end
  end

  describe '#ensure_array' do
    it_behaves_like 'array parser'
    it_behaves_like 'empty array creator for unmet objects', except: Array

    it 'and returns nil with default: nil option' do
      expect(call_for(true, default: nil)).to be_nil
      expect(call_for(true, default: 1)).to eq 1
    end
  end

  describe '#ensure_array!' do
    it_behaves_like 'array parser'
    it_behaves_like(
      'banger for unmet objects', except: Array,
      message: /should be an Array/
    )
  end
end

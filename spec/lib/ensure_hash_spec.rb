require 'spec_helper'

class Tester
  using EnsureIt if ENSURE_IT_REFINES

  def ensure_hash(*args)
    obj.ensure_hash(*args)
  end

  def ensure_hash!(*args)
    obj.ensure_hash!(*args)
  end
end

describe EnsureIt do
  shared_examples 'hash parser' do
    it 'and returns self for array' do
      obj = {some: 0, 'key' => 1}
      expect(call_for(obj)).to eq obj
    end

    it 'symbolizes keys with symbolize_keys option' do
      obj = {some: 0, 'key' => 1, Object => 'strange'}
      expect(call_for(obj, symbolize_keys: true)).to eq(some: 0, key: 1)
    end
  end

  describe '#ensure_hash' do
    it_behaves_like 'hash parser'
    it_behaves_like 'empty hash creator for unmet objects', except: Hash

    it 'and returns nil with wrong: nil option' do
      expect(call_for(true, wrong: nil)).to be_nil
      expect(call_for(true, wrong: 1)).to eq 1
    end
  end

  describe '#ensure_hash!' do
    it_behaves_like 'hash parser'
    it_behaves_like(
      'banger for unmet objects', except: Hash,
      message: /should be a Hash/
    )
  end
end

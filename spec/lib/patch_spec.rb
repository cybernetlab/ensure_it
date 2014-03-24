require 'spec_helper'

class PatchTestClass; end
module PatchTestWrapper; end

describe EnsureIt do
  describe '::patch' do
    it 'is private' do
      expect { EnsureIt.patch(PatchTestClass) {} }.to raise_error NoMethodError
    end

    it 'includes methods to object' do
      expect { PatchTestWrapper.obj.test_method }.to raise_error NoMethodError
      EnsureIt.send(:patch, PatchTestClass, &proc do
        def test_method
          'test result'
        end
      end)
      result =
        if ENSURE_IT_REFINES
          PatchTestWrapper.module_eval do
            using EnsureIt
            PatchTestClass.new.test_method
          end
        else
          PatchTestClass.new.test_method
        end
      expect(result).to eq 'test result'
    end
  end
end

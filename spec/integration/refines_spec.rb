require 'spec_helper'

describe EnsureIt do
  describe 'refines requirement' do
    before { @backup = ENSURE_IT_REFINED }

    after do
      if defined? ENSURE_IT_REFINED
        Object.instance_eval { remove_const(:ENSURE_IT_REFINED) }
      end
      ENSURE_IT_REFINED = @backup
    end

    def load_refines
      if defined? ENSURE_IT_REFINED
        Object.instance_eval { remove_const(:ENSURE_IT_REFINED) }
      end
      load(File.expand_path(
        File.join(%w(.. .. .. lib ensure_it_refined.rb)), __FILE__
      ))
    end

    if RUBY_VERSION >= '2.1'
      it 'defines ENSURE_IT_REFINED' do
        load_refines
        expect(ENSURE_IT_REFINED).to be_true
      end
    else
      it %q{warns with ruby < 2.1 and doesn't defines ENSURE_IT_REFINED} do
        expect {
          load_refines
        }.to warn('EsureIt: refines supported only for ruby >= 2.1')
        expect(ENSURE_IT_REFINED).to be_false
      end
    end
  end
end

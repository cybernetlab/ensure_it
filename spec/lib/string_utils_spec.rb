require 'spec_helper'

describe EnsureIt::StringUtils do
  describe '.ensure_name' do
    NAMES = %w(local @inst_var @@class_var setter= getter checker?
               bang! Object)

    if ENSURE_IT_REFINED != true
      it 'checks str argument' do
        str = 'str'
        expect(str).to receive(:ensure_string!).and_call_original
        described_class.ensure_name(str)
      end

      it 'checks name_of option' do
        str = 'str'
        expect(str).to receive(:ensure_symbol).with(
          downcase: true,
          values: EnsureIt::StringUtils::NAME_TYPES,
          default: EnsureIt::StringUtils::NAME_TYPES[0]
        ).and_call_original
        described_class.ensure_name('str', name_of: str)
      end
    end

    describe 'name_of: :class' do
      it 'rejects non-class-name strings' do
        expect(
          described_class.ensure_name('just text', name_of: :class)
        ).to be_nil
        expect(
          described_class.ensure_name('just_text', name_of: :class)
        ).to be_nil
      end

      it 'accpets class-name strings' do
        expect(
          described_class.ensure_name('Namespace::SomeClass', name_of: :class)
        ).to eq 'Namespace::SomeClass'
      end

      it 'accpets low-cased class-name strings with downcase option' do
        expect(
          described_class.ensure_name(
            'low/cased_class', name_of: :class, downcase: true
          )
        ).to eq 'Low::CasedClass'
      end

      it 'rejects non-existent class names with exist option' do
        expect(Object.const_defined?(:UnknownClass)).to be_false
        expect(
          described_class.ensure_name(
            'UnknownClass', name_of: :class, exist: true
          )
        ).to be_nil
        expect(
          described_class.ensure_name(
            'unknown_class', name_of: :class, exist: true, downcase: true
          )
        ).to be_nil
      end

      it 'accepts exists classes with exist option' do
        expect(
          described_class.ensure_name('Object', name_of: :class, exist: true)
        ).to eq 'Object'
        expect(
          described_class.ensure_name(
            'object', name_of: :class, exist: true, downcase: true
          )
        ).to eq 'Object'
      end
    end

    describe 'name_of: :local' do
      it 'converts names to local variable name' do
        expect(NAMES.map { |x|
          described_class.ensure_name(x, name_of: :local)
        }).to match_array(
          %w(local inst_var class_var setter getter checker
             bang) + [nil]
        )
      end
    end

    describe 'name_of: :instance_variable' do
      it 'converts names to instance variable name' do
        expect(NAMES.map { |x|
          described_class.ensure_name(x, name_of: :instance_variable)
        }).to match_array(
          %w(@local @inst_var @class_var @setter @getter @checker
             @bang) + [nil]
        )
      end
    end

    describe 'name_of: :class_variable' do
      it 'converts names to class variable name' do
        expect(NAMES.map { |x|
          described_class.ensure_name(x, name_of: :class_variable)
        }).to match_array(
          %w(@@local @@inst_var @@class_var @@setter @@getter @@checker
             @@bang) + [nil]
        )
      end
    end

    describe 'name_of: :setter' do
      it 'converts names to setter method name' do
        expect(NAMES.map { |x|
          described_class.ensure_name(x, name_of: :setter)
        }).to match_array(
          %w(local= inst_var= class_var= setter= getter= checker=
             bang=) + [nil]
        )
      end
    end

    describe 'name_of: :getter' do
      it 'converts names to getter method name' do
        expect(NAMES.map { |x|
          described_class.ensure_name(x, name_of: :getter)
        }).to match_array(
          %w(local inst_var class_var setter getter checker
             bang) + [nil]
        )
      end
    end

    describe 'name_of: :checker' do
      it 'converts names to checker method name' do
        expect(NAMES.map { |x|
          described_class.ensure_name(x, name_of: :checker)
        }).to match_array(
          %w(local? inst_var? class_var? setter? getter? checker?
             bang?) + [nil]
        )
      end
    end

    describe 'name_of: :bang' do
      it 'converts names to bang method name' do
        expect(NAMES.map { |x|
          described_class.ensure_name(x, name_of: :bang)
        }).to match_array(
          %w(local! inst_var! class_var! setter! getter! checker!
             bang!) + [nil]
        )
      end
    end

    describe 'name_of: :method' do
      it 'converts names to method name' do
        expect(NAMES.map { |x|
          described_class.ensure_name(x, name_of: :method)
        }).to match_array(
          %w(local inst_var class_var setter= getter checker?
             bang!) + [nil]
        )
      end
    end
  end
end

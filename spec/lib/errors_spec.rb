require 'spec_helper'

describe EnsureIt::Error do
  it 'is StandardError' do
    expect(described_class < StandardError).to be_true
  end
end

describe EnsureIt do
  describe '.raise_error' do
    after { EnsureIt::Config.instance_variable_set(:@errors, nil) }

    it 'raises EnsureIt::Error by default' do
      expect {
        call_error(:test_method)
      }.to raise_error EnsureIt::Error
    end

    it 'raisesspecified error and message' do
      expect {
        call_error(:test_method, error: ArgumentError, message: 'test')
      }.to raise_error ArgumentError, 'test'
    end

    it 'raises error with callers backtrace' do
      backtrace = nil
      begin
        call_error(:test_method)
      rescue EnsureIt::Error => e
        backtrace = e.backtrace
      end
      expect(backtrace.first).to match(/\A#{__FILE__}:#{__LINE__ - 4}:/)
    end

    context 'standard errors' do
      before { EnsureIt.config.errors :standard }
    end

    context 'smart errors' do
      before { EnsureIt.config.errors :smart }

      def test_unknown_caller
        local = ''
        local
          .to_s; call_error(:to_s, message: '#{subject}')
      end

      def test_local_caller
        local = ''
        local.to_s; call_error(:to_s, message: '#{subject}')
      end

      def test_instance_caller
        @instance = ''
        @instance.to_s; call_error(:to_s, message: '#{subject}')
      end

      def test_class_caller
        backup = $VERBOSE
        $VERBOSE = nil
        @@class = ''
        @@class.to_s; call_error(:to_s, message: '#{subject}')
        $VERBOSE = backup
      end

      def test_method_1_caller
        local = ''
        local.to_sym.to_s; call_error(:to_s, message: '#{subject}')
      end

      def test_method_2_caller
        local = ''
        local.to_sym().to_s; call_error(:to_s, message: '#{subject}')
      end

      def test_argument_1_caller(arg_1)
        arg_1.to_s; call_error(:to_s, message: '#{subject}')
      end

      def test_argument_2_caller(*args)
        args.to_s; call_error(:to_s, message: '#{subject}')
      end

      def test_argument_3_caller(arg_1 = 'test')
        arg_1.to_s; call_error(:to_s, message: '#{subject}')
      end

      def test_argument_4_caller(arg_1: 'test')
        arg_1.to_s; call_error(:to_s, message: '#{subject}')
      end

      def test_argument_5_caller(**opts)
        opts.to_s; call_error(:to_s, message: '#{subject}')
      end

      def test_argument_6_caller(&block)
        block.to_s; call_error(:to_s, message: '#{subject}')
      end

      {
        unknown: %q{subject of 'to_s' method inside 'test_unknown_caller' method},
        local: %q{local variable 'local' inside 'test_local_caller' method},
        instance: %q{instance variable '@instance' inside 'test_instance_caller' method},
        class: %q{class variable '@@class' inside 'test_class_caller' method},
        method_1: %q{return value of 'to_sym' method inside 'test_method_1_caller' method},
        method_2: %q{return value of method inside 'test_method_2_caller' method},
        argument_1:  %q{argument 'arg_1' of 'test_argument_1_caller' method},
        argument_2:  %q{argument '*args' of 'test_argument_2_caller' method},
        argument_3:  %q{optional argument 'arg_1' of 'test_argument_3_caller' method},
        argument_4:  %q{key argument 'arg_1' of 'test_argument_4_caller' method},
        argument_5:  %q{key argument '**opts' of 'test_argument_5_caller' method},
        argument_6:  %q{block argument '&block' of 'test_argument_6_caller' method},
      }.each do |var, message|
        it "finds #{var} name" do
          m = method("test_#{var}_caller")
          args = [true] * (m.arity < 0 ? -m.arity - 1 : m.arity)
          error = get_error { m.call(*args) }
          expect(error.message).to eq message
        end
      end
    end
  end
end

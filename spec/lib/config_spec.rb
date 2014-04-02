require 'spec_helper'

describe EnsureIt::Config do
  describe '.errors' do
    after { described_class.instance_variable_set(:@errors, nil) }

    it 'gives :smart by default' do
      expect(described_class.errors).to eq :smart
    end

    it 'calls setter if value given' do
      expect(described_class).to receive(:errors=).with(:standard)
      described_class.errors :standard
    end
  end

  describe '.errors=' do
    after { described_class.instance_variable_set(:@errors, nil) }

    it 'allows to change value' do
      described_class.errors = :standard
      expect(described_class.errors).to eq :standard
    end

    it 'sets to default for wrong values' do
      described_class.errors = :bad_value
      expect(described_class.errors).to eq :smart
    end
  end

  describe '.error_class' do
    after { described_class.instance_variable_set(:@error_class, nil) }

    it 'gives EsnureIt::Error by default' do
      expect(described_class.error_class).to eq EnsureIt::Error
    end

    it 'calls setter if value given' do
      expect(described_class).to receive(:error_class=).with(ArgumentError)
      described_class.error_class ArgumentError
    end
  end

  describe '.error_class=' do
    after { described_class.instance_variable_set(:@error_class, nil) }

    it 'allows to change value' do
      described_class.error_class = ArgumentError
      expect(described_class.error_class).to eq ArgumentError
    end

    it "doesn't change value to wrong classes" do
      described_class.error_class = ArgumentError
      described_class.error_class = Object
      expect(described_class.error_class).to eq ArgumentError
    end
  end

end

describe EnsureIt do
  describe '.config' do
    it 'returns Config module' do
      expect(described_class.config).to eq EnsureIt::Config
    end
  end

  describe '.configure' do
    it 'returns Config module' do
      expect(described_class.config).to eq EnsureIt::Config
    end

    it 'yields block with Config module' do
      expect { |b|
        described_class.configure(&b)
      }.to yield_with_args(EnsureIt::Config)
    end
  end
end

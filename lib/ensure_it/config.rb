module EnsureIt
  module Config
    ERRORS = %i(smart standard)

    def self.errors(value = nil)
      value.nil? ? @errors ||= ERRORS.first : self.errors = value
    end

    def self.errors=(value)
      value = value.to_sym if value.is_a?(String)
      @errors = ERRORS.include?(value) ? value : ERRORS.first
    end

    def self.error_class(value = nil)
      value.nil? ? @error_class ||= EnsureIt::Error : self.error_class = value
    end

    def self.error_class=(value)
      return unless value.is_a?(Class) && value <= Exception
      @error_class = value
    end
  end

  def self.config
    Config
  end

  def self.configure
    yield(Config) if block_given?
    Config
  end
end

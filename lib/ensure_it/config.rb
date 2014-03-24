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
  end

  def self.config
    Config
  end

  def self.configure
    yield(Config) if block_given?
    Config
  end
end

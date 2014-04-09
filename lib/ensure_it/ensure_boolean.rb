module EnsureIt
  TRUE_NAMES = %w(true y yes 1)

  patch Object do
    def ensure_boolean(default: nil, **opts)
      default
    end

    def ensure_boolean!(**opts)
      EnsureIt.raise_error(:ensure_boolean!,
                           **EnsureIt::ensure_boolean_error(**opts))
    end
  end

  patch String do
    def ensure_boolean(default: nil, strings: false, **opts)
      return TRUE_NAMES.include?(downcase) if strings == true
      default
    end

    def ensure_boolean!(strings: false, **opts)
      return TRUE_NAMES.include?(downcase) if strings == true
      EnsureIt.raise_error(:ensure_boolean!,
                           **EnsureIt::ensure_boolean_error(**opts))
    end
  end

  patch Symbol do
    def ensure_boolean(default: nil, strings: false, **opts)
      return TRUE_NAMES.include?(to_s.downcase) if strings == true
      default
    end

    def ensure_boolean!(strings: false, **opts)
      return TRUE_NAMES.include?(to_s.downcase) if strings == true
      EnsureIt.raise_error(:ensure_boolean!,
                           **EnsureIt::ensure_boolean_error(**opts))
    end
  end

  patch Numeric do
    def ensure_boolean(default: nil, numbers: true, positive: false, **opts)
      return positive == true ? self > 0 : self != 0 if numbers == true
      default
    end

    def ensure_boolean!(numbers: true, positive: false, **opts)
      return positive == true ? self > 0 : self != 0 if numbers == true
      EnsureIt.raise_error(:ensure_boolean!,
                           **EnsureIt::ensure_boolean_error(**opts))
    end
  end

  patch TrueClass do
    def ensure_boolean(**opts)
      self
    end
    alias_method :ensure_boolean!, :ensure_boolean
  end

  patch FalseClass do
    def ensure_boolean(**opts)
      self
    end
    alias_method :ensure_boolean!, :ensure_boolean
  end

  def self.ensure_boolean_error(**opts)
    unless opts.key?(:message)
      opts[:message] = '#{subject} should be a boolean or be able' \
                       ' to convert to it'
    end
    opts
  end
end

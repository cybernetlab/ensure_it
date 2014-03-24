module EnsureIt
  FLOAT_REGEXP = /\A[+\-]?(?:\d+(?:\.\d*)?|\d*\.\d+)(?:[eE][+\-]?\d+)?\z/

  patch Object do
    def ensure_float(**opts)
      opts.key?(:wrong) ? opts[:wrong] : nil
    end

    def ensure_float!(**opts)
      opts[:message] ||= '#{subject} should be a float or be able' \
                         ' to convert to it'
      EnsureIt.raise_error(:ensure_float!, **opts)
    end
  end

  patch String do
    using EnsureIt if ENSURE_IT_REFINES

    def ensure_float(**opts)
      self =~ FLOAT_REGEXP ? to_f : nil
    end

    def ensure_float!(**opts)
      ensure_float(**opts) || super(**opts)
    end
  end

  patch Integer do
    def ensure_float(**opts)
      to_f
    end
    alias_method :ensure_float!, :ensure_float
  end

  patch Float do
    def ensure_float(**opts)
      self
    end
    alias_method :ensure_float!, :ensure_float
  end

  patch Rational do
    def ensure_float(**opts)
      to_f
    end
    alias_method :ensure_float!, :ensure_float
  end
end

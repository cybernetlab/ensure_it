module EnsureIt
  OCT_REGEXP = /\A0\d+\z/
  INT_REGEXP = /\A[+\-]?\d[\d_]*\z/
  HEX_REGEXP = /\A0x[0-9a-zA-Z]+\z/
  BIN_REGEXP = /\A0b[01]+\z/

  patch Object do
    def ensure_integer(**opts)
      opts.key?(:wrong) ? opts[:wrong] : nil
    end

    def ensure_integer!(**opts)
      opts[:message] ||= '#{subject} should be an integer or be able' \
                         ' to convert to it'
      EnsureIt.raise_error(:ensure_integer!, **opts)
    end
  end

  patch String do
    using EnsureIt if ENSURE_IT_REFINES

    def ensure_integer(**opts)
      case self
      when OCT_REGEXP then opts[:octal] == true ? self.to_i(8) : self.to_i
      when INT_REGEXP then self.to_i
      when HEX_REGEXP then self[2..-1].to_i(16)
      when BIN_REGEXP then self[2..-1].to_i(2)
      else nil
      end
    end

    def ensure_integer!(**opts)
      ensure_integer(**opts) || super(**opts)
    end
  end

  patch Integer do
    def ensure_integer(**opts)
      self
    end
    alias_method :ensure_integer!, :ensure_integer
  end

  patch Float do
    def ensure_integer(**opts)
      round
    end
    alias_method :ensure_integer!, :ensure_integer
  end

  patch Rational do
    def ensure_integer(**opts)
      round
    end
    alias_method :ensure_integer!, :ensure_integer
  end

  patch TrueClass do
    using EnsureIt if ENSURE_IT_REFINES

    def ensure_integer(**opts)
      if opts[:boolean] == true || opts[:boolean].is_a?(Integer)
        opts[:boolean] == true ? 1 : opts[:boolean]
      else
        nil
      end
    end

    def ensure_integer!(**opts)
      if opts[:boolean] == true || opts[:boolean].is_a?(Integer)
        opts[:boolean] == true ? 1 : opts[:boolean]
      else
        super(**opts)
      end
    end
  end

  patch FalseClass do
    using EnsureIt if ENSURE_IT_REFINES

    def ensure_integer(**opts)
      opts[:boolean] == true || opts[:boolean].is_a?(Integer) ? 0 : nil
    end

    def ensure_integer!(**opts)
      opts[:boolean] == true || opts[:boolean].is_a?(Integer) ? 0 : super(**opts)
    end
  end
end

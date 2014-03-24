module EnsureIt
  INTEGER_REGEXP = /\A[+\-]?\d+\z/

  patch Object do
    def ensure_integer(**opts); end

    def ensure_integer!(**opts)
      #msg =
      #  if opts[:numbers] == true
      #    '#{subject} should be an integer or be able to convert to it'
      #  else
      #    '#{subject} should be a String or a Symbol'
      #  end
      EnsureIt.raise_error(
        :ensure_integer!,
        '#{subject} should be an integer or be able to convert to it',
        **opts
      )
    end
  end

  patch String do
    using EnsureIt if ENSURE_IT_REFINES

    def ensure_integer(**opts)
      INTEGER_REGEXP =~ self ? self.to_i : nil
    end

    def ensure_integer!(**opts)
      INTEGER_REGEXP =~ self ? self.to_i : super(**opts)
    end
  end

  patch Symbol do
    using EnsureIt if ENSURE_IT_REFINES

    def ensure_integer(**opts)
      str = self.to_s
      INTEGER_REGEXP =~ str ? str.to_i : nil
    end

    def ensure_integer!(**opts)
      str = self.to_s
      INTEGER_REGEXP =~ str ? str.to_i : super(**opts)
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

module EnsureIt
  patch Object do
    def ensure_string(**opts); end

    def ensure_string!(**opts)
      msg =
        if opts[:numbers] == true
          '#{subject} should be a String, Symbol, Numeric or Rational'
        else
          '#{subject} should be a String or a Symbol'
        end
      EnsureIt.raise_error(:ensure_string!, msg, **opts)
    end
  end

  patch String do
    def ensure_string(**opts)
      self
    end
    alias_method :ensure_string!, :ensure_string
  end

  patch Symbol do
    def ensure_string(**opts)
      to_s
    end
    alias_method :ensure_string!, :ensure_string
  end

  patch Numeric do
    using EnsureIt if ENSURE_IT_REFINES

    def ensure_string(**opts)
      opts[:numbers] == true ? to_s : nil
    end

    def ensure_string!(**opts)
      opts[:numbers] == true ? to_s : super(**opts)
    end
  end
end

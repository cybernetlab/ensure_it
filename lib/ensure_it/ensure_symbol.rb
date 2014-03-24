module EnsureIt
  patch Object do
    def ensure_symbol(**opts); end

    def ensure_symbol!(**opts)
      opts[:message] ||= '#{subject} should be a Symbol or a String'
      EnsureIt.raise_error(:ensure_symbol!, **opts)
    end
  end

  patch String do
    def ensure_symbol(**opts)
      to_sym
    end
    alias_method :ensure_symbol!, :ensure_symbol
  end

  patch Symbol do
    def ensure_symbol(**opts)
      self
    end
    alias_method :ensure_symbol!, :ensure_symbol
  end
end

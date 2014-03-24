module EnsureIt
  patch Object do
    def ensure_symbol(**opts); end

    def ensure_symbol!(**opts)
      EnsureIt.raise_error(
        :ensure_symbol!,
        '#{subject} should be a Symbol or a String',
        **opts
      )
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

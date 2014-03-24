module EnsureIt
  patch Object do
    def ensure_symbol; end

    def ensure_symbol!
      EnsureIt.raise_error(
        :ensure_symbol!,
        '#{subject} should be a Symbol or a String'
      )
    end
  end

  patch String do
    def ensure_symbol
      to_sym
    end

    def ensure_symbol!
      to_sym
    end
  end

  patch Symbol do
    def ensure_symbol
      self
    end

    def ensure_symbol!
      self
    end
  end
end

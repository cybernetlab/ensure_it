module EnsureIt
  patch Object do
    def ensure_symbol(default: nil, **opts)
      default
    end

    def ensure_symbol!(default: nil, **opts)
      EnsureIt.raise_error(
        :ensure_symbol!,
        **EnsureIt.ensure_symbol_error_options(**opts)
      )
    end
  end

  patch String do
    def ensure_symbol(default: nil, values: nil, downcase: nil, **opts)
      value = downcase == true ? self.downcase.to_sym : to_sym
      if values.nil? || values.is_a?(Array) && values.include?(value)
        value
      else
        default
      end
    end

    def ensure_symbol!(default: nil, values: nil, downcase: nil, **opts)
      value = downcase == true ? self.downcase.to_sym : to_sym
      if values.nil? || values.is_a?(Array) && values.include?(value)
        return value
      end
      EnsureIt.raise_error(
        :ensure_symbol!,
        **EnsureIt.ensure_symbol_error_options(**opts)
      )
    end
  end

  patch Symbol do
    def ensure_symbol(default: nil, values: nil, downcase: nil, **opts)
      value = downcase == true ? self.to_s.downcase.to_sym : self
      if values.nil? || values.is_a?(Array) && values.include?(value)
        value
      else
        default
      end
    end

    def ensure_symbol!(default: nil, values: nil, downcase: nil, **opts)
      value = downcase == true ? self.to_s.downcase.to_sym : self
      if values.nil? || values.is_a?(Array) && values.include?(value)
        return value
      end
      EnsureIt.raise_error(
        :ensure_symbol!,
        **EnsureIt.ensure_symbol_error_options(**opts)
      )
    end
  end

  def self.ensure_symbol_error_options(**opts)
    unless opts.key?(opts[:message])
      opts[:message] = '#{subject} should be' +
        if opts[:values].is_a?(Array)
          " one of #{opts[:values]}"
        else
          ' a Symbol or a String'
        end
    end
    opts
  end
end

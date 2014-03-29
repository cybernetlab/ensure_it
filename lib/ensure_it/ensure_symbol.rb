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
    def ensure_symbol(default: nil, values: nil, **opts)
      if values.nil?
        to_sym
      elsif values.is_a?(Array)
        value = to_sym
        values.include?(value) ? value : default
      else
        default
      end
    end

    def ensure_symbol!(default: nil, values: nil, **opts)
      return to_sym if values.nil?
      if values.is_a?(Array)
        value = to_sym
        return value if values.include?(value)
      end
      EnsureIt.raise_error(
        :ensure_symbol!,
        **EnsureIt.ensure_symbol_error_options(**opts)
      )
    end
  end

  patch Symbol do
    def ensure_symbol(default: nil, values: nil, **opts)
      if values.nil? || values.is_a?(Array) && values.include?(self)
        self
      else
        default
      end
    end

    def ensure_symbol!(default: nil, values: nil, **opts)
      if values.nil? || values.is_a?(Array) && values.include?(self)
        return self
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

module EnsureIt
  patch Object do
    def ensure_string(default: nil, **opts)
      default
    end

    def ensure_string!(default: nil, **opts)
      EnsureIt.raise_error(
        :ensure_string!,
        **EnsureIt.ensure_string_error_options(**opts)
      )
    end
  end

  patch String do
    def ensure_string(default: nil, values: nil, downcase: nil, **opts)
      value = downcase == true ? self.downcase : self
      if values.nil? || values.is_a?(Array) && values.include?(value)
        value
      else
        default
      end
    end

    def ensure_string!(default: nil, values: nil, downcase: nil, **opts)
      value = downcase == true ? self.downcase : self
      if values.nil? || values.is_a?(Array) && values.include?(value)
        return value
      end
      EnsureIt.raise_error(
        :ensure_string!,
        **EnsureIt.ensure_string_error_options(**opts)
      )
    end
  end

  patch Symbol do
    def ensure_string(default: nil, values: nil, downcase: nil, **opts)
      value = downcase == true ? to_s.downcase : to_s
      if values.nil? || values.is_a?(Array) && values.include?(value)
        value
      else
        default
      end
    end

    def ensure_string!(default: nil, values: nil, downcase: nil, **opts)
      value = downcase == true ? to_s.downcase : to_s
      if values.nil? || values.is_a?(Array) && values.include?(value)
        return value
      end
      EnsureIt.raise_error(
        :ensure_string!,
        **EnsureIt.ensure_string_error_options(**opts)
      )
    end
  end

  patch Numeric do
    using EnsureIt if ENSURE_IT_REFINED

    def ensure_string(default: nil, values: nil, numbers: false, **opts)
      return default if numbers != true
      value = to_s
      values.is_a?(Array) && !values.include?(value) ? default : value
    end

    def ensure_string!(default: nil, values: nil, numbers: false, **opts)
      if numbers == true
        value = to_s
        return value if !values.is_a?(Array) || values.include?(value)
      end
      EnsureIt.raise_error(
        :ensure_string!,
        **EnsureIt.ensure_string_error_options(**opts)
      )
    end
  end

  def self.ensure_string_error_options(**opts)
    unless opts.key?(opts[:message])
      opts[:message] =
        if opts[:numbers] == true
          '#{subject} should be a String, Symbol, Numeric or Rational'
        else
          '#{subject} should be a String or a Symbol'
        end
    end
    opts
  end
end

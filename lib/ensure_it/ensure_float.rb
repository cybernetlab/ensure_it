module EnsureIt
  FLOAT_REGEXP = /\A[+\-]?(?:\d+(?:\.\d*)?|\d*\.\d+)(?:[eE][+\-]?\d+)?\z/

  patch Object do
    def ensure_float(default: nil, **opts)
      default
    end

    def ensure_float!(default: nil, **opts)
      EnsureIt.raise_error(
        :ensure_float!,
        **EnsureIt::ensure_float_error_options(**opts)
      )
    end
  end

  patch String do
    def ensure_float(default: nil, values: nil, **opts)
      return default unless self =~ FLOAT_REGEXP
      value = to_f
      if values.nil? || values.is_a?(Array) && values.include?(value)
        value
      else
        default
      end
    end

    def ensure_float!(default: nil, values: nil, **opts)
      if self =~ FLOAT_REGEXP
        value = to_f
        if values.nil? || values.is_a?(Array) && values.include?(value)
          return value
        end
      end
      EnsureIt.raise_error(
        :ensure_float!,
        **EnsureIt::ensure_float_error_options(**opts)
      )
    end
  end

  patch Integer do
    def ensure_float(default: nil, values: nil, **opts)
      return to_f if values.nil?
      value = to_f
      values.is_a?(Array) && values.include?(value) ? value : default
    end

    def ensure_float!(default: nil, values: nil, **opts)
      return to_f if values.nil?
      value = to_f
      return values if values.is_a?(Array) && values.include?(value)
      EnsureIt.raise_error(
        :ensure_float!,
        **EnsureIt::ensure_float_error_options(**opts)
      )
    end
  end

  patch Float do
    def ensure_float(default: nil, values: nil, **opts)
      if values.nil? || values.is_a?(Array) && values.include?(self)
        self
      else
        default
      end
    end

    def ensure_float!(default: nil, values: nil, **opts)
      if values.nil? || values.is_a?(Array) && values.include?(self)
        return self
      end
      EnsureIt.raise_error(
        :ensure_float!,
        **EnsureIt::ensure_float_error_options(**opts)
      )
    end
  end

  patch Rational do
    def ensure_float(default: nil, values: nil, **opts)
      return to_f if values.nil?
      value = to_f
      values.is_a?(Array) && values.include?(value) ? value : default
    end

    def ensure_float!(default: nil, values: nil, **opts)
      return to_f if values.nil?
      value = to_f
      return values if values.is_a?(Array) && values.include?(value)
      EnsureIt.raise_error(
        :ensure_float!,
        **EnsureIt::ensure_float_error_options(**opts)
      )
    end
  end

  def self.ensure_float_error_options(**opts)
    unless opts.key?(:message)
      opts[:message] = '#{subject} should be a float or be able' \
                       ' to convert to it'
    end
    opts
  end
end

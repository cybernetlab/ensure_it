module EnsureIt
  OCT_REGEXP = /\A0\d+\z/
  INT_REGEXP = /\A[+\-]?\d[\d_]*\z/
  HEX_REGEXP = /\A0x[0-9a-zA-Z]+\z/
  BIN_REGEXP = /\A0b[01]+\z/

  patch Object do
    def ensure_integer(default: nil, **opts)
      default
    end

    def ensure_integer!(default: nil, **opts)
      EnsureIt.raise_error(
        :ensure_integer!,
        **EnsureIt::ensure_integer_error_options(**opts)
      )
    end
  end

  patch String do
    def ensure_integer(default: nil, values: nil, **opts)
      value = case self
      when OCT_REGEXP then opts[:octal] == true ? self.to_i(8) : self.to_i
      when INT_REGEXP then self.to_i
      when HEX_REGEXP then self[2..-1].to_i(16)
      when BIN_REGEXP then self[2..-1].to_i(2)
      else return default
      end
      if values.nil? || values.is_a?(Array) || values.include?(self)
        value
      else
        default
      end
    end

    def ensure_integer!(default: nil, values: nil, **opts)
      value = case self
      when OCT_REGEXP then opts[:octal] == true ? self.to_i(8) : self.to_i
      when INT_REGEXP then self.to_i
      when HEX_REGEXP then self[2..-1].to_i(16)
      when BIN_REGEXP then self[2..-1].to_i(2)
      else
        EnsureIt.raise_error(
          :ensure_integer!,
          **EnsureIt::ensure_integer_error_options(**opts)
        )
      end
      if values.nil? || values.is_a?(Array) || values.include?(self)
        return value
      end
      EnsureIt.raise_error(
        :ensure_integer!,
        **EnsureIt::ensure_integer_error_options(**opts)
      )
    end
  end

  patch Integer do
    def ensure_integer(default: nil, values: nil, **opts)
      if values.nil? || values.is_a?(Array) && values.include?(self)
        self
      else
        default
      end
    end

    def ensure_integer!(default: nil, values: nil, **opts)
      if values.nil? || values.is_a?(Array) && values.include?(self)
        return self
      end
      EnsureIt.raise_error(
        :ensure_integer!,
        **EnsureIt::ensure_integer_error_options(**opts)
      )
    end
  end

  patch Float do
    def ensure_integer(default: nil, values: nil, **opts)
      return round if values.nil?
      value = round
      values.is_a?(Array) && values.include?(value) ? value : default
    end

    def ensure_integer!(default: nil, values: nil, **opts)
      return round if values.nil?
      value = round
      return value if values.is_a?(Array) && values.include?(value)
      EnsureIt.raise_error(
        :ensure_integer!,
        **EnsureIt::ensure_integer_error_options(**opts)
      )
    end
  end

  patch Rational do
    def ensure_integer(default: nil, values: nil, **opts)
      return round if values.nil?
      value = round
      values.is_a?(Array) && values.include?(value) ? value : default
    end

    def ensure_integer!(default: nil, values: nil, **opts)
      return round if values.nil?
      value = round
      return value if values.is_a?(Array) && values.include?(value)
      EnsureIt.raise_error(
        :ensure_integer!,
        **EnsureIt::ensure_integer_error_options(**opts)
      )
    end
  end

  patch TrueClass do
    def ensure_integer(default: nil, values: nil, boolean: nil, **opts)
      if boolean == true || boolean.is_a?(Integer)
        value = boolean == true ? 1 : boolean
        values.is_a?(Array) && !values.include?(value) ? default : value
      else
        default
      end
    end

    def ensure_integer!(default: nil, values: nil, boolean: nil, **opts)
      if boolean == true || boolean.is_a?(Integer)
        value = boolean == true ? 1 : boolean
        return value unless values.is_a?(Array) && !values.include?(value)
      end
      EnsureIt.raise_error(
        :ensure_integer!,
        **EnsureIt::ensure_integer_error_options(**opts)
      )
    end
  end

  patch FalseClass do
    def ensure_integer(default: nil, values: nil, boolean: nil, **opts)
      return 0 if (boolean == true || boolean.is_a?(Integer)) &&
                  (!values.is_a?(Array) || values.include?(0))
      default
    end

    def ensure_integer!(default: nil, values: nil, boolean: nil, **opts)
      return 0 if (boolean == true || boolean.is_a?(Integer)) &&
                  (!values.is_a?(Array) || values.include?(0))
      EnsureIt.raise_error(
        :ensure_integer!,
        **EnsureIt::ensure_integer_error_options(**opts)
      )
    end
  end

  def self.ensure_integer_error_options(**opts)
    unless opts.key?(:message)
      opts[:message] = '#{subject} should be an integer or be able' \
                       ' to convert to it'
    end
    opts
  end
end

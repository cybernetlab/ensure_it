module EnsureIt
  patch Object do
    def ensure_integer(default: nil, **opts)
      default
    end

    def ensure_integer!(**opts)
      EnsureIt.raise_error(:ensure_integer!,
                           **EnsureIt::ensure_integer_error(**opts))
    end
  end

  patch String do
    def ensure_integer(default: nil, **opts)
      catch(:wrong) { return EnsureIt.ensure_integer_string(self, **opts) }
      default
    end

    def ensure_integer!(**opts)
      catch(:wrong) { return EnsureIt.ensure_integer_string(self, **opts) }
      EnsureIt.raise_error(:ensure_integer!,
                           **EnsureIt::ensure_integer_error(**opts))
    end
  end

  patch Integer do
    def ensure_integer(default: nil, **opts)
      return self if opts.empty?
      catch(:wrong) { return EnsureIt.ensure_integer(self, **opts) }
      default
    end

    def ensure_integer!(**opts)
      return self if opts.empty?
      catch(:wrong) { return EnsureIt.ensure_integer(self, **opts) }
      EnsureIt.raise_error(:ensure_integer!,
                           **EnsureIt::ensure_integer_error(**opts))
    end
  end

  patch Float do
    def ensure_integer(default: nil, **opts)
      return round if opts.empty?
      catch(:wrong) { return EnsureIt.ensure_integer(round, **opts) }
      default
    end

    def ensure_integer!(**opts)
      return round if opts.empty?
      catch(:wrong) { return EnsureIt.ensure_integer(round, **opts) }
      EnsureIt.raise_error(:ensure_integer!,
                           **EnsureIt::ensure_integer_error(**opts))
    end
  end

  patch Rational do
    def ensure_integer(default: nil, **opts)
      return round if opts.empty?
      catch(:wrong) { return EnsureIt.ensure_integer(round, **opts) }
      default
    end

    def ensure_integer!(**opts)
      return round if opts.empty?
      catch(:wrong) { return EnsureIt.ensure_integer(round, **opts) }
      EnsureIt.raise_error(:ensure_integer!,
                           **EnsureIt::ensure_integer_error(**opts))
    end
  end

  patch TrueClass do
    def ensure_integer(default: nil, boolean: nil, **opts)
      if boolean == true || boolean.is_a?(Integer)
        value = boolean == true ? 1 : boolean
        return value if opts.empty?
        catch(:wrong) { return EnsureIt.ensure_integer(value, **opts) }
      end
      default
    end

    def ensure_integer!(boolean: nil, **opts)
      if boolean == true || boolean.is_a?(Integer)
        value = boolean == true ? 1 : boolean
        return value if opts.empty?
        catch(:wrong) { return EnsureIt.ensure_integer(value, **opts) }
      end
      EnsureIt.raise_error(:ensure_integer!,
                           **EnsureIt::ensure_integer_error(**opts))
    end
  end

  patch FalseClass do
    def ensure_integer(default: nil, boolean: nil, **opts)
      if boolean == true || boolean.is_a?(Integer)
        return 0 if opts.empty?
        catch(:wrong) { return EnsureIt.ensure_integer(0, **opts) }
      end
      default
    end

    def ensure_integer!(default: nil, values: nil, boolean: nil, **opts)
      if boolean == true || boolean.is_a?(Integer)
        return 0 if opts.empty?
        catch(:wrong) { return EnsureIt.ensure_integer(0, **opts) }
      end
      EnsureIt.raise_error(:ensure_integer!,
                           **EnsureIt::ensure_integer_error(**opts))
    end
  end

  OCT_REGEXP = /\A0\d+\z/
  INT_REGEXP = /\A[+\-]?\d[\d_]*\z/
  HEX_REGEXP = /\A0x[0-9a-zA-Z]+\z/
  BIN_REGEXP = /\A0b[01]+\z/

  def self.ensure_integer(int, values: nil, **opts)
    throw :wrong if values.is_a?(Array) && !values.include?(int)
    int
  end

  def self.ensure_integer_string(str, **opts)
    value = case str
      when OCT_REGEXP then opts[:octal] == true ? str.to_i(8) : str.to_i
      when INT_REGEXP then str.to_i
      when HEX_REGEXP then str[2..-1].to_i(16)
      when BIN_REGEXP then str[2..-1].to_i(2)
      else throw :wrong
    end
    return value if opts.empty?
    return EnsureIt.ensure_integer(value, **opts)
  end

  def self.ensure_integer_error(**opts)
    unless opts.key?(:message)
      opts[:message] = '#{subject} should be an integer or be able' \
                       ' to convert to it'
    end
    opts
  end
end

module EnsureIt
  FLOAT_REGEXP = /\A[+\-]?(?:\d+(?:\.\d*)?|\d*\.\d+)(?:[eE][+\-]?\d+)?\z/

  patch Object do
    def ensure_float(default: nil, **opts)
      default
    end

    def ensure_float!(**opts)
      EnsureIt.raise_error(:ensure_float!,
                           **EnsureIt::ensure_float_error(**opts))
    end
  end

  patch String do
    def ensure_float(default: nil, **opts)
      return default unless self =~ FLOAT_REGEXP
      catch(:wrong) { return EnsureIt.ensure_float(to_f, **opts) }
      default
    end

    def ensure_float!(**opts)
      if self =~ FLOAT_REGEXP
        catch(:wrong) { return EnsureIt.ensure_float(to_f, **opts) }
      end
      EnsureIt.raise_error(:ensure_float!,
                           **EnsureIt::ensure_float_error(**opts))
    end
  end

  patch Integer do
    def ensure_float(default: nil, **opts)
      return to_f if opts.nil?
      catch(:wrong) { return EnsureIt.ensure_float(to_f, **opts) }
      default
    end

    def ensure_float!(**opts)
      return to_f if opts.nil?
      catch(:wrong) { return EnsureIt.ensure_float(to_f, **opts) }
      EnsureIt.raise_error(:ensure_float!,
                           **EnsureIt::ensure_float_error(**opts))
    end
  end

  patch Float do
    def ensure_float(default: nil, **opts)
      return self if opts.nil?
      catch(:wrong) { return EnsureIt.ensure_float(self, **opts) }
      default
    end

    def ensure_float!(**opts)
      return self if opts.nil?
      catch(:wrong) { return EnsureIt.ensure_float(self, **opts) }
      EnsureIt.raise_error(:ensure_float!,
                           **EnsureIt::ensure_float_error(**opts))
    end
  end

  patch Rational do
    def ensure_float(default: nil, **opts)
      return to_f if opts.nil?
      catch(:wrong) { return EnsureIt.ensure_float(to_f, **opts) }
      default
    end

    def ensure_float!(**opts)
      return to_f if opts.nil?
      catch(:wrong) { return EnsureIt.ensure_float(to_f, **opts) }
      EnsureIt.raise_error(:ensure_float!,
                           **EnsureIt::ensure_float_error(**opts))
    end
  end

  def self.ensure_float(float, values: nil, **opts)
    throw :wrong if values.is_a?(Array) && !values.include?(float)
    float
  end

  def self.ensure_float_error(**opts)
    unless opts.key?(:message)
      opts[:message] = '#{subject} should be a float or be able' \
                       ' to convert to it'
    end
    opts
  end
end

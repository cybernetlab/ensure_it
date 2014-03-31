module EnsureIt
  patch Object do
    def ensure_symbol(default: nil, **opts)
      default
    end

    def ensure_symbol!(**opts)
      EnsureIt.raise_error(:ensure_symbol!,
                           **EnsureIt.ensure_symbol_error(**opts))
    end
  end

  patch String do
    def ensure_symbol(default: nil, **opts)
      return to_sym if opts.empty?
      catch :wrong do
        return EnsureIt.ensure_symbol(to_sym, **opts)
      end
      default
    end

    def ensure_symbol!(**opts)
      return to_sym if opts.empty?
      catch :wrong do
        return EnsureIt.ensure_symbol(to_sym, **opts)
      end
      EnsureIt.raise_error(:ensure_symbol!,
                           **EnsureIt.ensure_symbol_error(**opts))
    end
  end

  patch Symbol do
    def ensure_symbol(default: nil, **opts)
      return self if opts.empty?
      catch :wrong do
        return EnsureIt.ensure_symbol(self, **opts)
      end
      default
    end

    def ensure_symbol!(default: nil, **opts)
      return self if opts.empty?
      catch :wrong do
        return EnsureIt.ensure_symbol(self, **opts)
      end
      EnsureIt.raise_error(:ensure_symbol!,
                           **EnsureIt.ensure_symbol_error(**opts))
    end
  end

  def self.ensure_symbol(sym, values: nil, downcase: nil, name_of: nil, **opts)
    if name_of.nil?
      value = downcase == true ? sym.to_s.downcase.to_sym : sym
    else
      value = EnsureIt::StringUtils.ensure_name(
        sym.to_s, downcase: downcase, name_of: name_of, **opts
      )
      throw :wrong if value.nil?
      value = value.to_sym
    end
    throw :wrong if values.is_a?(Array) && !values.include?(value)
    value
  end

  def self.ensure_symbol_error(**opts)
    unless opts.key?(:message)
      opts[:message] = '#{subject} should be a Symbol or a String'
      if opts.key?(:name_of)
        opts[:message] << " and should be a name of #{opts[:name_of]}"
      end
      if opts[:values].is_a?(Array)
        opts[:message] << " and should contained in #{opts[:values]}"
      end
    end
    opts
  end
end

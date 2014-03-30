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
    def ensure_symbol(default: nil,
                      values: nil,
                      downcase: nil,
                      name_of: nil,
                      **opts)
      value = if name_of.nil?
        downcase == true ? self.downcase.to_sym : to_sym
      else
        EnsureIt::StringUtils.ensure_name(
          self, downcase: downcase, name_of: name_of, **opts
        )
      end
      if !value.nil? &&
         (values.nil? || values.is_a?(Array) && values.include?(value))
        value
      else
        default
      end
    end

    def ensure_symbol!(default: nil,
                       values: nil,
                       downcase: nil,
                       name_of: nil,
                       **opts)
      value = if name_of.nil?
        downcase == true ? self.downcase.to_sym : to_sym
      else
        EnsureIt::StringUtils.ensure_name(
          self, downcase: downcase, name_of: name_of, **opts
        )
      end
      if !value.nil? &&
         (values.nil? || values.is_a?(Array) && values.include?(value))
        return value
      end
      EnsureIt.raise_error(
        :ensure_symbol!,
        **EnsureIt.ensure_symbol_error_options(**opts)
      )
    end
  end

  patch Symbol do
    def ensure_symbol(default: nil,
                      values: nil,
                      downcase: nil,
                      name_of: nil,
                      **opts)
      if name_of.nil?
        value = downcase == true ? self.to_s.downcase.to_sym : self
      else
        value = EnsureIt::StringUtils.ensure_name(
          to_s, downcase: downcase, name_of: name_of, **opts
        )
        value = value.to_sym unless value.nil?
      end
      if !value.nil? &&
         (values.nil? || values.is_a?(Array) && values.include?(value))
        value
      else
        default
      end
    end

    def ensure_symbol!(default: nil,
                       values: nil,
                       downcase: nil,
                       name_of: nil,
                       **opts)
      if name_of.nil?
        value = downcase == true ? self.to_s.downcase.to_sym : self
      else
        value = EnsureIt::StringUtils.ensure_name(
          to_s, downcase: downcase, name_of: name_of, **opts
        )
        value = value.to_sym unless value.nil?
      end
      if !value.nil? &&
         (values.nil? || values.is_a?(Array) && values.include?(value))
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

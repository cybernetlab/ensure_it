# @!method ensure_it(opts = {})
#
# Ensures that subject is a symbol. For symbols return self, for strings,
# value, converted to symbol, for others - value, specified in default option
# or nil.
#
# @param [Hash] opts the options
# @option opts [Object] :default (nil) default value for wrong subject
# @option opts [Array] :values
# @option opts [Boolean] :downcase
# @option opts [<String, Symbol>] :name_of

# @private
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
    def ensure_string(default: nil,
                      values: nil,
                      downcase: nil,
                      name_of: nil,
                      **opts)
      value = if name_of.nil?
        downcase == true ? self.downcase : self
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

    def ensure_string!(default: nil,
                       values: nil,
                       downcase: nil,
                       name_of: nil,
                       **opts)
      value = if name_of.nil?
        downcase == true ? self.downcase : self
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
        :ensure_string!,
        **EnsureIt.ensure_string_error_options(**opts)
      )
    end
  end

  patch Symbol do
    def ensure_string(default: nil,
                      values: nil,
                      downcase: nil,
                      name_of: nil,
                      **opts)
      if name_of.nil?
        value = downcase == true ? to_s.downcase : to_s
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

    def ensure_string!(default: nil,
                       values: nil,
                       downcase: nil,
                       name_of: nil,
                       **opts)
      if name_of.nil?
        value = downcase == true ? to_s.downcase : to_s
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

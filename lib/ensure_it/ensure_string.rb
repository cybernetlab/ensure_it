# @!method ensure_string(opts = {})
#
# Ensures that subject is a string. Without options for symbols returns
# converted to string value, for strings, returns self, for others - value,
# specified in default option or nil. With `numbers: true` option, also
# converts numbers to string.
#
# With `downcase: true` option downcases value.
#
# If `values` option specified, returns default value if converted value
# is not included in specified array. **Warning:** there are no type checks
# of array elements, so if you, for example, specify array of integers here,
# this method will allways return default value.
#
# `name_of` option, if specified, should be one of: `:local`,
# `:instance_variable`, `:class_variable`, `:setter`, `:getter`, `:checker`,
# `:bang`, `:method`, `:class` or its string equivalents. This option allow you
# to be ensured that return value is a valid name of local variable,
# instance variable, class variable, setter method, getter method, checker
# method (ending with `?`), bang method (ending with `!`), any method or
# class, respectively to option values above. See examples below for details.
# If you want to convert underscored downcased notations of classes, use
# `downcase: true` option. Also, with `name_of: :class`, `exist: true` option
# can specified to ensures that class exists.
#
# @example  usage of `name_of` option
# ```ruby
#   'some text'.ensure_string(name_of: :local) # => nil
#   'some_text'.ensure_string(name_of: :local) # => 'some_text'
#
#   'some_text'.ensure_string(name_of: :instance_variable) # => '@some_text'
#   '@some_text'.ensure_string(name_of: :instance_variable) # => '@some_text'
#   'some_text='.ensure_string(name_of: :instance_variable) # => '@some_text'
#
#   'some_text'.ensure_string(name_of: :setter) # => 'some_text='
#   'some_text?'.ensure_string(name_of: :setter) # => 'some_text='
#   'some_text='.ensure_string(name_of: :setter) # => 'some_text='
#
#   'some_text'.ensure_string(name_of: :class) # => nil
#   'Some::Text'.ensure_string(name_of: :class) # => Some::Text
#   'some_text'.ensure_string(name_of: :class, downcase: true) # => SomeText
#   'some/text'.ensure_string(name_of: :class, downcase: true) # => Some::Text
#   'Some::Text'.ensure_string(name_of: :class, exist: true) # => nil
#   'Object'.ensure_string(name_of: :class, exist: true) # => 'Object'
# ```
#
# @param [Hash] opts the options
# @option opts [Object] :default (nil) default value for wrong subject
# @option opts [Array] :values an array of possible values
# @option opts [Boolean] :downcase convert string to downcase
# @option opts [<String, Symbol>] :name_of string should be a name of variable
#   or method

# @private
module EnsureIt
  patch Object do
    def ensure_string(default: nil, **opts)
      default
    end

    def ensure_string!(**opts)
      EnsureIt.raise_error(:ensure_string!,
                           **EnsureIt.ensure_string_error(**opts))
    end
  end

  patch String do
    def ensure_string(default: nil, **opts)
      return self if opts.empty?
      catch :wrong do
        return EnsureIt.ensure_string(self, **opts)
      end
      default
    end

    def ensure_string!(**opts)
      return self if opts.empty?
      catch :wrong do
        return EnsureIt.ensure_string(self, **opts)
      end
      EnsureIt.raise_error(:ensure_string!,
                           **EnsureIt.ensure_string_error(**opts))
    end
  end

  patch Symbol do
    def ensure_string(default: nil, **opts)
      return to_s if opts.empty?
      catch :wrong do
        return EnsureIt.ensure_string(to_s, **opts)
      end
      default
    end

    def ensure_string!(**opts)
      return to_s if opts.empty?
      catch :wrong do
        return EnsureIt.ensure_string(to_s, **opts)
      end
      EnsureIt.raise_error(:ensure_string!,
                           **EnsureIt.ensure_string_error(**opts))
    end
  end

  patch Numeric do
    using EnsureIt if ENSURE_IT_REFINED

    def ensure_string(default: nil, numbers: false, **opts)
      return default if numbers != true
      catch :wrong do
        return EnsureIt.ensure_string(to_s, **opts)
      end
      default
    end

    def ensure_string!(numbers: false, **opts)
      if numbers == true
        catch :wrong do
          return EnsureIt.ensure_string(to_s, **opts)
        end
      end
      EnsureIt.raise_error(
        :ensure_string!,
        **EnsureIt.ensure_string_error(numbers: numbers, **opts)
      )
    end
  end

  def self.ensure_string(str, values: nil, downcase: nil, name_of: nil, **opts)
    if name_of.nil?
      value = downcase == true ? str.downcase : str
    else
      value = EnsureIt::StringUtils.ensure_name(
        str, downcase: downcase, name_of: name_of, **opts
      )
      throw :wrong if value.nil?
    end
    throw :wrong if values.is_a?(Array) && !values.include?(value)
    value
  end

  def self.ensure_string_error(**opts)
    unless opts.key?(:message)
      opts[:message] = '#{subject} should be a String or a Symbol'
      if opts[:numbers] == true
        opts[:message] << ' or a Numeric'
      end
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

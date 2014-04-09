module EnsureIt
  patch Object do
    def ensure_class(*args, default: nil, **opts)
      default
    end

    def ensure_class!(*args, **opts)
      opts[:message] ||= '#{subject} should be a class'
      EnsureIt.raise_error(:ensure_class!, **opts)
    end
  end

  patch Class do
    def ensure_class(*args, default: nil, **opts)
      return self if args.empty? && opts.empty?
      catch(:wrong) { return EnsureIt.ensure_class(self, *args, **opts) }
      default
    end

    def ensure_class!(*args, **opts)
      return self if args.empty? && opts.empty?
      catch(:wrong) { return EnsureIt.ensure_class(self, *args, **opts) }
      args = args.map!(&:name).join(', ')
      opts[:message] ||=
        "\#{subject} should subclass or extend all of ['#{args}']"
      EnsureIt.raise_error(:ensure_class!, **opts)
    end
  end

  patch String do
    using EnsureIt if ENSURE_IT_REFINED

    def ensure_class(*args, default: nil, strings: nil, **opts)
      return default if strings != true
      catch :wrong do
        return EnsureIt.ensure_class_string(self, *args, **opts)
      end
      default
    end

    def ensure_class!(*args, strings: nil, **opts)
      if strings == true
        catch :wrong do
          return EnsureIt.ensure_class_string(self, *args, **opts)
        end
      end
      args = args.map!(&:name).join(', ')
      unless opts.key?(:message)
        opts[:message] = '#{subject} should'
        opts[:message] << ' be a class or a name of class,' if string == true
        opts[:message] << " that subclass or extend all of ['#{args}']"
      end
      EnsureIt.raise_error(:ensure_class!, **opts)
    end
  end

  def self.ensure_class_string(str, *args, **opts)
    opts.delete(:name_of)
    opts.delete(:exist)
    name = EnsureIt::StringUtils.ensure_name(
      str, name_of: :class, exist: true, **opts
    )
    throw :wrong if name.nil?
    EnsureIt.ensure_class(Object.const_get(name), *args, **opts)
  end

  def self.ensure_class(klass, *args, values: nil, **opts)
    args.select! { |x| x.is_a?(Module) }
    throw :wrong unless args.all? { |x| klass <= x }
    throw :wrong if values.is_a?(Array) && !values.include?(klass)
    klass
  end
end

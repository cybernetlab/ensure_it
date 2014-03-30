module EnsureIt
  patch Object do
    def ensure_class(*args, default: nil, **opts)
      default
    end

    def ensure_class!(*args, default: nil, **opts)
      opts[:message] ||= '#{subject} should be a class'
      EnsureIt.raise_error(:ensure_class!, **opts)
    end
  end

  patch Class do
    def ensure_class(*args, default: nil, values: nil, **opts)
      args.select! { |x| x.is_a?(Module) }
      return default unless args.all? { |x| self <= x }
      if values.nil? || values.is_a?(Array) && values.include?(self)
        self
      else
        default
      end
    end

    def ensure_class!(*args, default: nil, values: nil, **opts)
      args.select! { |x| x.is_a?(Module) }
      if args.all? { |x| self <= x } &&
         (values.nil? || values.is_a?(Array) && values.include?(self))
        return self
      end
      args = args.map!(&:name).join(', ')
      opts[:message] ||=
        "\#{subject} should subclass or extend all of ['#{args}']"
      EnsureIt.raise_error(:ensure_class!, **opts)
    end
  end

  patch String do
    using EnsureIt if ENSURE_IT_REFINED

    def ensure_class(*args, default: nil, values: nil, string: nil, **opts)
      return default if string != true
      opts.delete(:name_of)
      opts.delete(:exist)
      name = EnsureIt::StringUtils.ensure_name(
        self, name_of: :class, exist: true, **opts
      )
      return default if name.nil?
      Object.const_get(name)
            .ensure_class(*args, default: default, values: values)
    end

    def ensure_class!(*args, default: nil, values: nil, string: nil, **opts)
      if string == true
        opts.delete(:name_of)
        opts.delete(:exist)
        name = EnsureIt::StringUtils.ensure_name(
          self, name_of: :class, exist: true, **opts
        )
        unless name.nil?
          klass = Object.const_get(name)
          args.select! { |x| x.is_a?(Module) }
          if args.all? { |x| klass <= x } &&
             (values.nil? || values.is_a?(Array) && values.include?(klass))
            return klass
          end
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
end

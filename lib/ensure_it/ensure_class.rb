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
end

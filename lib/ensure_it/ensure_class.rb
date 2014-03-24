module EnsureIt
  patch Object do
    def ensure_class(*args, **opts)
      opts.key?(:wrong) ? opts[:wrong] : nil
    end

    def ensure_class!(*args, **opts)
      opts[:message] ||= '#{subject} should be a class'
      EnsureIt.raise_error(:ensure_class!, **opts)
    end
  end

  patch Class do
    using EnsureIt

    def ensure_class(*args, **opts)
      args.select! { |x| x.is_a?(Module) }
      args.all? { |x| self <= x } ? self : super(**opts)
    end

    def ensure_class!(*args, **opts)
      args.select! { |x| x.is_a?(Module) }
      return self if args.all? { |x| self <= x }
      args = args.map!(&:name).join(', ')
      opts[:message] ||=
        "\#{subject} should subclass or extend all of ['#{args}']"
      EnsureIt.raise_error(:ensure_class!, **opts)
    end
  end
end

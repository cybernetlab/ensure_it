module EnsureIt
  patch Object do
    def ensure_hash(*args, default: {}, **opts)
      default
    end

    def ensure_hash!(*args, **opts)
      opts[:message] ||= '#{subject} should be a Hash'
      EnsureIt.raise_error(:ensure_hash!, **opts)
    end
  end

  patch Hash do
    using EnsureIt if ENSURE_IT_REFINED

    def ensure_hash(*args, default: {}, **opts)
      return self if opts.empty? || opts[:symbolize_keys] != true
      Hash[map { |k, v| [k.ensure_symbol, v] }.reject { |x| x[0].nil? }]
    end
    alias_method :ensure_hash!, :ensure_hash
  end
end

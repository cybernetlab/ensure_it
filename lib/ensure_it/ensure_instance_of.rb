module EnsureIt
  patch Object do
    def ensure_instance_of(klass, default: nil, **opts)
      unless klass.is_a?(Class)
        fail(
          ArgumentError,
          'Wrong class argument for #ensure_instance_of specified'
        )
      end
      is_a?(klass) ? self : default
    end

    def ensure_instance_of!(klass, default: nil, **opts)
      unless klass.is_a?(Class)
        fail(
          ArgumentError,
          'Wrong class argument for #ensure_instance_of specified'
        )
      end
      return self if is_a?(klass)
      opts[:message] ||=
        "\#{subject} should be an instance of '#{klass.name}' class"
      EnsureIt.raise_error(:ensure_instance_of!, **opts)
    end
  end
end

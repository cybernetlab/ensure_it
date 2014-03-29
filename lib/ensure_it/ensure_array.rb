module EnsureIt
  patch Object do
    def ensure_array(*args, default: [], **opts)
      default
    end

    def ensure_array!(*args, default: nil, **opts)
      opts[:message] ||= '#{subject} should be an Array'
      EnsureIt.raise_error(:ensure_array!, **opts)
    end
  end

  patch Array do
    using EnsureIt if ENSURE_IT_REFINED

    if ENSURE_IT_REFINED
      def ensure_array(*args, values: nil, **opts)
        arr = self
        args.each do |arg|
          arg = arg.ensure_symbol || next
          arr =
            if arg.to_s.index('ensure_') == 0
              case arg
              when :ensure_symbol then map { |x| x.ensure_symbol }
              when :ensure_symbol! then map { |x| x.ensure_symbol! }
              when :ensure_string then map { |x| x.ensure_string }
              when :ensure_string! then map { |x| x.ensure_string! }
              when :ensure_integer then map { |x| x.ensure_integer }
              when :ensure_integer! then map { |x| x.ensure_integer! }
              when :ensure_float then map { |x| x.ensure_float }
              when :ensure_float! then map { |x| x.ensure_float! }
              when :ensure_array then map { |x| x.ensure_array }
              when :ensure_array! then map { |x| x.ensure_array! }
              end
            else
              arr.map(&arg)
            end
        end
        return arr if opts.empty?
        arr = arr.map { |x| x } if arr == self
        arr.flatten! if opts[:flatten] == true
        arr.select! { |x| values.include?(x) } if values.is_a?(Array)
        opts[:sorted] ||= opts.delete(:ordered) if opts.key?(:ordered)
        arr.sort! if opts.key?(:sorted)
        arr.reverse! if opts[:sorted].ensure_symbol == :desc
        arr.compact! if opts[:compact] == true
        arr
      end
    else
      def ensure_array(*args, values: nil, **opts)
        arr = self
        args.each do |arg|
          arg = arg.ensure_symbol || next
          arr = arr.map(&arg)
        end
        return arr if opts.empty?
        arr = arr.map { |x| x } if arr == self
        arr.flatten! if opts[:flatten] == true
        arr.select! { |x| values.include?(x) } if values.is_a?(Array)
        opts[:sorted] ||= opts.delete(:ordered) if opts.key?(:ordered)
        arr.sort! if opts.key?(:sorted)
        arr.reverse! if opts[:sorted].ensure_symbol == :desc
        arr.compact! if opts[:compact] == true
        arr
      end
    end
    alias_method :ensure_array!, :ensure_array
  end
end

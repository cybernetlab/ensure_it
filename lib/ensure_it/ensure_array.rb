module EnsureIt
  patch Object do
    def ensure_array(*args, default: [], **opts)
      default
    end

    def ensure_array!(*args, **opts)
      opts[:message] ||= '#{subject} should be an Array'
      EnsureIt.raise_error(:ensure_array!, **opts)
    end
  end

  patch Array do
    using EnsureIt if ENSURE_IT_REFINED

    ENSURES = %i(ensure_symbol ensure_symbol! ensure_string ensure_string!
                 ensure_integer ensure_integer! ensure_float ensure_float!
                 ensure_array ensure_array! ensure_class ensure_class!)

    OPERATIONS = %i(compact flatten reverse rotate shuffle sort sort_desc uniq)


    if ENSURE_IT_REFINED
      def ensure_array(*args, values: nil, **opts)
        arr = self
        args.each do |arg|
          if arg.is_a?(Proc)
            arr = arr.map(arg)
            next
          end
          arg = arg.ensure_symbol || next
          case arg
          when *ENSURES
            arr = case arg
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
            when :ensure_class then map { |x| x.ensure_class }
            when :ensure_class! then map { |x| x.ensure_class! }
            end
          when *OPERATIONS
            op = arg == :sort_desc ? :sort : arg
            arr = arr.send(op)
            arr = arr.reverse if arg == :sort_desc
          else
            arr = arr.map { |x| x.respond_to?(arg) ? x.send(arg) : nil }
          end
        end
        values.is_a?(Array) ? arr & values : arr
      end
    else
      def ensure_array(*args, values: nil, **opts)
        arr = self
        args.each do |arg|
          if arg.is_a?(Proc)
            arr = arr.map(arg)
            next
          end
          arg = arg.ensure_symbol || next
          case arg
          when *ENSURES then arr = arr.map(&arg)
          when *OPERATIONS
            op = arg == :sort_desc ? :sort : arg
            arr = arr.send(op)
            arr = arr.reverse if arg == :sort_desc
          else
            arr = arr.map { |x| x.respond_to?(arg) ? x.send(arg) : nil }
          end
        end
        values.is_a?(Array) ? arr & values : arr
      end
    end
    alias_method :ensure_array!, :ensure_array
  end
end

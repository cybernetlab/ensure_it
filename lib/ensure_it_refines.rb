if RUBY_VERSION >= '2.1'
  ENSURE_IT_REFINES = true
else
  warn 'EsureIt: refines supported only for ruby >= 2.1'
end

require 'ensure_it'

module EnsureIt
  module RefinesDynamicCaller
    using EnsureIt

    def ensure_symbol; ensure_symbol; end
    def ensure_symbol!; ensure_symbol!; end
    def ensure_string; ensure_string; end
    def ensure_string!; ensure_string!; end
    def ensure_integer; ensure_integer; end
    def ensure_integer!; ensure_integer!; end
    def ensure_float; ensure_float; end
    def ensure_float!; ensure_float!; end
  end
end

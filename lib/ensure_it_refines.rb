if RUBY_VERSION >= '2.1'
  ENSURE_IT_REFINES = true
else
  warn 'EsureIt: refines supported only for ruby >= 2.1'
end

require 'ensure_it'

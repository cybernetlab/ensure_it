if RUBY_VERSION >= '2.1'
  ENSURE_IT_REFINES = true
else
  ENSURE_IT_REFINES = false
  warn 'EsureIt: refines supported only for ruby >= 2.1'
end

require 'ensure_it'

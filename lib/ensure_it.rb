if RUBY_VERSION < '2.0.0'
  fail %q{EnsureIt: library doesn't support ruby < 2.0.0}
end

defined?(ENSURE_IT_REFINES) || ENSURE_IT_REFINES = false

require File.join %w(ensure_it version)
require File.join %w(ensure_it config)
require File.join %w(ensure_it errors)
require File.join %w(ensure_it patch)
require File.join %w(ensure_it ensure_symbol)

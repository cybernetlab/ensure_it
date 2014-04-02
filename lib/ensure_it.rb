if RUBY_VERSION < '2.0.0'
  fail %q(EnsureIt: library doesn't support ruby < 2.0.0)
end

defined?(ENSURE_IT_REFINED) || ENSURE_IT_REFINED = false

#
module EnsureIt
  # dummy module for eager usage
  module StringUtils
    def self.ensure_name(*args); end
  end

  def self.refined?
    ENSURE_IT_REFINED == true
  end
end

require File.join %w(ensure_it version)
require File.join %w(ensure_it config)
require File.join %w(ensure_it errors)
require File.join %w(ensure_it patch)
require File.join %w(ensure_it ensure_symbol)
require File.join %w(ensure_it ensure_string)
require File.join %w(ensure_it ensure_integer)
require File.join %w(ensure_it ensure_float)
require File.join %w(ensure_it ensure_array)
require File.join %w(ensure_it ensure_hash)
require File.join %w(ensure_it ensure_instance_of)
require File.join %w(ensure_it ensure_class)
require File.join %w(ensure_it string_utils)

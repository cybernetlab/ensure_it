if ENV['USE_REFINES'] == 'true'
  require 'ensure_it_refined'
else
  require 'ensure_it'
end

#if ENV['USE_COVERALLS'] == 'true'
#  # coveralls.io gem breaks build with our smart errors due to TracePoint
#  # conflicts, so build it separetly
#  # TODO: find better way to resolve this issue
#
#  EnsureIt.configure do |config|
#    config.errors = :standard
#  end
#
require 'coveralls'
Coveralls.wear!
#end


Dir[File.join(File.dirname(__FILE__), 'support', '**', '*.rb')].each do |file|
  require file
end

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
end

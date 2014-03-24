#require 'coveralls'
#Coveralls.wear!

if ENV['USE_REFINES'] == 'true'
  require 'ensure_it_refines'
else
  require 'ensure_it'
end

Dir[File.join(File.dirname(__FILE__), 'support', '**', '*.rb')].each do |file|
  require file
end

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
end

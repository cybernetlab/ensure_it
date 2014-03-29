require 'rubygems'
require 'bundler/setup'
require 'ensure_it'

def test(arg)
  arg.ensure_symbol!
end

puts test(:symbol).inspect
puts test('string').inspect
puts test(0).inspect

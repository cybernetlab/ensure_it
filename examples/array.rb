require 'rubygems'
require 'bundler/setup'
require 'ensure_it'

class Awesome
  def self.define_getters(*args)
    args.ensure_array(:ensure_symbol, :compact).each do |n|
      define_method(n) { instance_variable_get("@#{n}") }
    end
  end
end

Awesome.define_getters(:one, 'two', nil, false, Object, :three)
puts Awesome.instance_methods(false).inspect #=> [:one, :two, :three]

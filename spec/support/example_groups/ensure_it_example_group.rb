#
# Helpers for ensure_it testing
#
# @author Alexey Ovchinnikov <alexiss@cybernetlab.ru>
#

class Tester
  attr_reader :obj

  def initialize(obj)
    @obj = obj
  end
end

module EnsureItExampleGroup
  def self.fake_method; end

  FIXNUM_MAX = (2 ** (0.size * 8 - 2) - 1)
  BIGNUM = FIXNUM_MAX + 100
  FIXNUM = FIXNUM_MAX - 100

  GENERAL_OBJECTS = [
    [], {}, FIXNUM, BIGNUM, 0.1, true, false, nil, 0..5,
    '2/3'.to_r, /regexp/, 'string', :symbol,
    ->{}, proc {}, method(:fake_method),
    Object.new, Class.new, Module.new, Struct.new(:field), Time.new
  ]

  def self.included(base)
    base.instance_eval do
      metadata[:type] = :ensure_it
    end
  end

  def general_objects(&block)
    enum = GENERAL_OBJECTS.each
    enum.define_singleton_method :except do |*classes|
      classes = classes.flatten.select { |x| x.is_a?(Class) }
      reject { |obj| classes.any? { |c| obj.is_a?(c) } }
    end
    block_given? ? enum.each(&block) : enum
  end

  def described_method
    group = example.metadata[:example_group]
    while group do
      break if group[:description][0] == '#'
      group = group[:example_group]
    end
    if group.nil?
      raise RuntimeError, 'No description, containing method name founded'
    end
    group[:description][1..-1].to_sym
  end

  def call_for(obj, *args)
    Tester.new(obj).send(described_method, *args)
  end

  def call_error(method_name, message, error_class = EnsureIt::Error, test = nil)
    EnsureIt.raise_error(method_name, message, error_class)
  end

  def get_error
    yield
  rescue EnsureIt::Error => e
    e
  end

  RSpec.configure do |config|
    config.include(
      self,
      type: :ensure_it,
      example_group: { file_path: /spec\/lib/ }
    )
  end
end

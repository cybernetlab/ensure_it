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
  def self.included(base)
    base.instance_eval do
      metadata[:type] = :ensure_it
    end
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

  def call_error(method_name, **opts)
    EnsureIt.raise_error(method_name, **opts)
  end

  RSpec.configure do |config|
    config.include(
      self,
      type: :ensure_it,
      example_group: { file_path: /spec\/lib/ }
    )
  end
end

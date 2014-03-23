# coding: utf-8
lib = File.expand_path(File.join('..', 'lib'), __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require File.join %w(ensure_it version)

Gem::Specification.new do |spec|
  spec.name          = 'ensure_it'
  spec.version       = EnsureIt::VERSION
  spec.authors       = ['Alexey Ovchinnikov']
  spec.email         = ['alexiss@cybernetlab.ru']
  spec.summary       = %q{Provides variables and arguments parsing}
  spec.description   = %q{Main goal of project is to provide fastest way to
                          every-method arguments and variables checks with
                          minimal coding requirements}
  spec.homepage      = 'http://github.com/cybernetlab/ensure_it'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler',    '~> 1.5'
  spec.add_development_dependency 'rake',       '~> 10.1'
  spec.add_development_dependency 'redcarpet',  '~> 3.1'
  spec.add_development_dependency 'yard',       '~> 0.8'
  spec.add_development_dependency 'rspec',      '~> 2.14'
end

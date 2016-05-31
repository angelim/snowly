# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'snowly/version'

Gem::Specification.new do |spec|
  spec.name          = "snowly"
  spec.version       = Snowly::VERSION
  spec.authors       = ["Alexandre Angelim"]
  spec.email         = ["angelim@angelim.com.br"]

  spec.summary       = %q{Snowplow Emitter Validator}
  spec.description   = %q{Simple tester for snowplow event emitions. Validates core, unstructured events and contexts JSON schemas}
  spec.homepage      = "https://github.com/angelim/snowly"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  
  spec.add_dependency 'json-schema', '~> 2.6'
  spec.add_dependency 'rack', '~> 1.6'
  spec.add_dependency 'activesupport', "> 3.0"

  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'snowplow-tracker', '~> 0.5'
  spec.add_development_dependency 'webmock', '~> 2.0'
end

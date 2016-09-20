# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'snowly/version'

Gem::Specification.new do |spec|
  spec.name          = "snowly"
  spec.version       = Snowly::VERSION
  spec.authors       = ["Alexandre Angelim"]
  spec.email         = ["angelim@angelim.com.br"]

  spec.summary       = %q{Snowplow Request Validator}
  spec.description   = %q{Snowly is a minimal collector implementation intended to validate your event tracking requests before emitting them to cloudfront or a closure collector.}
  spec.homepage      = "https://github.com/angelim/snowly"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   << 'snowly'
  spec.require_paths = ["lib"]

  
  spec.add_dependency 'json-schema', '~> 2.6'
  spec.add_dependency 'rack', '~> 1.6'
  spec.add_dependency 'activesupport', "~> 3.0"
  spec.add_dependency 'sinatra', '~> 1.4'
  spec.add_dependency 'sinatra-contrib', '~> 1.4'
  spec.add_dependency 'vegas', '~> 0.1'
  spec.add_dependency 'thin', '~> 1.7'

  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'pry-byebug', '~> 3.3'
  spec.add_development_dependency 'snowplow-tracker', '~> 0.5'
  spec.add_development_dependency 'webmock', '~> 2.0'
  spec.add_development_dependency "shotgun", '~> 0.9'
end

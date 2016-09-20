require 'active_support/core_ext'
require "pry"
require 'json'
require 'rack'
require 'json-schema'
require 'snowly/validators/self_desc'
require "snowly/version"
require 'snowly/each_validator'
require 'snowly/validator'
require 'snowly/schema_cache'

module Snowly
  mattr_accessor :development_iglu_resolver_path, :debug_mode, :logger
  
  @@development_iglu_resolver_path = ENV['DEVELOPMENT_IGLU_RESOLVER_PATH']
  @@debug_mode = false
  @@logger = Logger.new(STDOUT)

  def self.config
    yield self
  end
end


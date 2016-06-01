require 'active_support/core_ext'
require "pry"
require 'json'
require 'rack'
require 'json-schema'
require 'snowly/validators/self_desc'
require "snowly/version"
require 'snowly/validator'
require 'snowly/schema_cache'

module Snowly
  mattr_accessor :local_iglu_resolver_path, :debug_mode
  
  @@local_iglu_resolver_path = ENV['LOCAL_IGLU_RESOLVER_PATH']
  @@debug_mode = ENV['SNOWLY_DEBUG_MODE'] || false

  def self.config
    yield self
  end
end


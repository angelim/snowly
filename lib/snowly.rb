require 'json-schema'
require 'snowly/validators/self_desc'
require "pry"
require "snowly/version"
require 'json'
require 'rack'
require 'snowly/validator'
require 'snowly/schema_cache'
require 'active_support'

module Snowly
  mattr_accessor :local_iglu_resolver_path
  @@local_iglu_resolver_path = ENV['LOCAL_IGLU_RESOLVER_PATH']
  def self.config
    yield self
  end
end


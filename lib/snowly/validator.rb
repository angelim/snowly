require 'json-schema'
require 'snowly/request'
require 'snowly/custom_dependencies'
module Snowly
  class Validator
    attr_reader :request, :errors
    
    def initialize(query_string)
      @request = Request.new query_string
    end

    def protocol_schema
      @protocol_schema ||= JSON.parse File.read("lib/schemas/snowplow_protocol.json")
    end

    def valid?
      @errors == []
    end

    def validate
      @errors = JSON::Validator.fully_validate protocol_schema, request.as_hash
      valid?
    end
    
  end
end
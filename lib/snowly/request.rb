require 'snowly/transformer'
module Snowly
  class Request

    attr_reader :parsed_payload

    def initialize(payload)
      @parsed_payload = payload.is_a?(String) ? parse_query(payload) : payload
    end

    # Retuns request as json, after transforming parameters into column names
    # @return [String] encoded JSON
    def as_json
      @json ||= as_hash.to_json
    end

    # Retuns request as hash, after transforming parameters into column names
    # @return [Hash]
    def as_hash
      @hash ||= Transformer.transform(parsed_payload)
    end

    # Returns query parameters as hash
    # @return [Hash]
    def parse_query(query_string)
      @parsed_query ||= Rack::Utils.parse_nested_query(query_string)
    end
    
  end
end
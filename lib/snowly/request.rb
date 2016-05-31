require 'snowly/transformer'
module Snowly
  class Request
    attr_reader :query_string
    def initialize(query_string)
      @query_string = query_string
    end

    # Retuns request as json, after transforming parameters into column names
    # @return [String] encoded JSON
    def as_json
      @json ||= as_hash.to_json
    end

    # Retuns request as hash, after transforming parameters into column names
    # @return [Hash]
    def as_hash
      @hash ||= Transformer.transform(parsed_query)
    end

    # Returns query parameters as hash
    # @return [Hash]
    def parsed_query
      @parsed_query ||= Rack::Utils.parse_nested_query(query_string)
    end
    
  end
end
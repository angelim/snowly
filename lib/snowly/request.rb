require 'snowly/transformer'
module Snowly
  class Request
    attr_reader :query_string
    def initialize(query_string)
      @query_string = query_string
    end

    def as_json
      @json ||= as_hash.to_json
    end

    def as_hash
      @hash ||= Transformer.transform(parsed_query).with_indifferent_access
    end

    def parsed_query
      @parsed_query ||= Rack::Utils.parse_nested_query(query_string)
    end
    
  end
end
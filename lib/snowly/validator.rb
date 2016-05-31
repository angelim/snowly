# Performs the validation for the root attributes and associated contexts and unstructured events.
require 'snowly/request'
require 'snowly/custom_dependencies'
module Snowly
  class Validator
    attr_reader :request, :errors

    def initialize(query_string)
      @request = Request.new query_string
      @errors = []
    end

    # Loads the protocol schema created to describe snowplow events table attributes
    # @return [Hash] parsed schema
    def protocol_schema
      @protocol_schema ||= JSON.parse File.read("lib/schemas/snowplow_protocol.json")
    end

    # @return [Hash] all contexts content and schema definitions
    def associated_contexts
      load_contexts request.as_hash['contexts']
    end

    # @return [Hash] all unstructured events content and schema definitions
    def associated_unstruct_event
      load_unstruct_event request.as_hash['unstruct_event']
    end

    # @return [Array<Hash>] all associated content
    def associated_elements
      (Array(associated_contexts) + Array(associated_unstruct_event)).compact
    end

    # Performs initial validation for associated contexts and loads their contents and definitions.
    # @return [Array<Hash>]
    def load_contexts(hash)
      return unless hash
      response = []
      unless hash['data']
        @errors << "All custom contexts must be contain a `data` element" and return
      end
      response << { content: hash['data'], definition: SchemaCache.instance[hash['schema']] }
      unless hash['data'].is_a? Array
        @errors << "All custom contexts must be wrapped in an Array" and return
      end
      hash['data'].each do |data_item|
        response << { content: data_item['data'], definition: SchemaCache.instance[data_item['schema']] }
      end
      response
    end

    # Performs initial validation for associated unstructured events and loads their contents and definitions.
    # @return [Array<Hash>]
    def load_unstruct_event(hash)
      return unless hash
      response = []
      unless hash['data']
        @errors << "All custom unstruct event must be contain a `data` element" and return
      end
      outer_data = hash['data']
      inner_data = outer_data['data']
      response << { content: outer_data, definition: SchemaCache.instance[hash['schema']] }
      response << { content: inner_data, definition: SchemaCache.instance[outer_data['schema']] }
      response
    end

    # Validates associated contexts and unstructured events
    def validate_associated
      return unless associated_elements
       associated_elements.each do |schema|
        this_error = JSON::Validator.fully_validate JSON.parse(schema[:definition]), schema[:content]
        @errors += this_error if this_error.count > 0
      end
    end

    # Validates root attributes for the events table
    def validate_root
      this_error = JSON::Validator.fully_validate protocol_schema, request.as_hash
      @errors += this_error if this_error.count > 0
    end

    # If request is valid
    # @return [true, false] if valid
    def valid?
      @errors == []
    end

    # Entry point for validation.
    def validate
      validate_root
      validate_associated
      valid?
    end
  end
end
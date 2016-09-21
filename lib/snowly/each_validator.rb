# Performs the validation for the root attributes and associated contexts and unstructured events.
require 'snowly/request'
require 'snowly/protocol_schema_finder'
require 'snowly/extensions/custom_dependencies'

module Snowly
  class EachValidator
    attr_reader :request, :errors

    def initialize(payload)
      @request = Request.new payload
      @errors = []
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

    def protocol_schema
      @protocol_schema ||= ProtocolSchemaFinder.new.schema
    end

    def as_hash
      { event_id: request.as_hash['event_id'], errors: errors, content: request.as_hash }
    end

    private

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
      schema = SchemaCache.instance[hash['schema']]
      response << { content: hash['data'], definition: schema, schema_name: hash['schema'] }
      unless hash['data'].is_a? Array
        @errors << "All custom contexts must be wrapped in an Array" and return
      end
      hash['data'].each do |data_item|
        schema = SchemaCache.instance[data_item['schema']]
        response << { content: data_item['data'], definition: schema, schema_name: data_item['schema'] }
      end
      response
    end

    def register_missing_schema(name)
      @errors << "#{ name } wasn't found in any resolvers."
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
      response << { content: outer_data, definition: SchemaCache.instance[hash['schema']], schema_name: hash['schema'] }
      response << { content: inner_data, definition: SchemaCache.instance[outer_data['schema']], schema_name: outer_data['schema'] }
      response
    end

    # Validates associated contexts and unstructured events
    def validate_associated
      return unless associated_elements
      missing_schemas, valid_elements = associated_elements.partition{ |el| el[:definition].blank? }
      missing_schemas.each { |element| register_missing_schema(element[:schema_name]) }
      valid_elements.each do |element|
        this_error = JSON::Validator.fully_validate JSON.parse(element[:definition]), element[:content]
        @errors += this_error if this_error.count > 0
      end
    end

    # Validates root attributes for the events table
    def validate_root
      this_error = JSON::Validator.fully_validate protocol_schema, request.as_hash
      @errors += this_error if this_error.count > 0
    end
  end
end
# Extended validation to require custom dependencies
# This validation allows the schema designer to define requirements based on other attribute content.
# @example Require apartment number if address type is `apartment`
# {
#   'address': { 'type': string' },
#   'adress_type': { 'type': 'string', 'enum': ['house', 'apartment']  },
#   'apartment_number': { 'type': 'number'},
#   'custom_dependencies': {
#     apartment_number: { 'address_type': 'apartment' }
#   }
# }
# In this example if the address type is 'house', apartment_number if not required.
# It only becomes a requirement if address type is set to 'apartment'.
require 'json-schema/attribute'

class CustomDependenciesAttribute < JSON::Schema::Attribute
  def self.validate(current_schema, data, fragments, processor, validator, options = {})
    return unless data.is_a?(Hash)
    current_schema.schema['custom_dependencies'].each do |property, dependency_value|
      next unless accept_value?(dependency_value)
      case dependency_value
      when Array
        dependency_value.each do |dependency_hash|
          validate_dependency(current_schema, data, property, dependency_hash, fragments, processor, self, options)
        end
      when Hash
        validate_dependency(current_schema, data, property, dependency_value, fragments, processor, self, options)
      end
    end
  end

  def self.validate_dependency(schema, data, property, dependency_hash, fragments, processor, attribute, options)
    key, value = Array(dependency_hash).flatten
    return unless data[key.to_s] == value.to_s
    return if data.has_key?(property.to_s)
    message = "The property '#{build_fragment(fragments)}' did not contain a required property of '#{property}' when property '#{key}' is '#{value}'"
    validation_error(processor, message, fragments, schema, attribute, options[:record_errors])
  end

  def self.accept_value?(value)
    value.is_a?(Array) || value.is_a?(Hash)
  end
end

# Registers custom dependencies for Draft-4. This used when evaluating the protocol schema
# snowly/schemas/snowplow_protocol.json
class RootExtendedSchema < JSON::Schema::Validator
  def initialize
    super
    extend_schema_definition("http://json-schema.org/draft-04/schema#")
    @attributes["custom_dependencies"] = CustomDependenciesAttribute
    @uri = URI.parse("http://json-schema.org/draft-04/schema")
  end
  JSON::Validator.register_validator(self.new)
end

# Registers custom dependencies for Snowplot Self-Describing schema. Contexts and Unstructure events derive from it.
class DescExtendedSchema < JSON::Schema::Validator
  def initialize
    super
    extend_schema_definition("http://iglucentral.com/schemas/com.snowplowanalytics.self-desc/schema/jsonschema/1-0-0#")
    @attributes["custom_dependencies"] = CustomDependenciesAttribute
    @uri = URI.parse("http://iglucentral.com/schemas/com.snowplowanalytics.self-desc/schema/jsonschema/1-0-0#")
  end
  JSON::Validator.register_validator(self.new)
end

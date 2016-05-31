# Register a validator for the self-describing schema.
# This is required to allow extended validations being attached to it.
require 'json-schema/validators/draft4'
module JSON
  class Schema
    class SelfDesc < Draft4
      URL = "http://iglucentral.com/schemas/com.snowplowanalytics.self-desc/schema/jsonschema/1-0-0#"
      def initialize
        super
        @uri = JSON::Util::URI.parse(URL)
      end

      JSON::Validator.register_validator(self.new)
    end
  end
end
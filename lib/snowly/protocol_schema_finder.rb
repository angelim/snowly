module Snowly
  class ProtocolSchemaFinder
    PROTOCOL_FILE_NAME = 'snowplow_protocol.json'
    attr_reader :schema

    def initialize(custom_schema = nil)
      @custom_schema = custom_schema
      @schema = load_protocol_schema
    end

    def find_protocol_schema
      return @custom_schema if @custom_schema
      if resolver && alternative_protocol_schema
        alternative_protocol_schema
      else
        File.expand_path("../../schemas/#{PROTOCOL_FILE_NAME}", __FILE__)
      end
    end

    def resolver
      Snowly.development_iglu_resolver_path
    end

    def alternative_protocol_schema
      Dir[File.join(resolver,"/**/*")].select{ |f| File.basename(f) == PROTOCOL_FILE_NAME }[0]
    end

    # Loads the protocol schema created to describe snowplow events table attributes
    # @return [Hash] parsed schema
    def load_protocol_schema
      JSON.parse File.read(find_protocol_schema)
    end
  end
end
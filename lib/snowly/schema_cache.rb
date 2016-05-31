# Caches schemas found during validation so they don't have to be
# retrieved a second time. Also uses the resolvers convert the iglu: location to an actual address (local or remote)/
require 'singleton'
module Snowly
  class SchemaCache
    include Singleton
    SNOWPLOW_IGLU_RESOLVER = 'http://iglucentral.com/schemas/'
    @@schema_cache = {}

    # Provides easy access to the schema cache based on its registered key
    # @param location [String] Location provided in the schema
    # @return [String] Json for schema
    def [](location)
      @@schema_cache[location] || save_in_cache(location)
    end

    # Resets the schema cache
    def reset_cache
      @@schema_cache = {}
    end

    # Accessor to the global cache
    def cache
      @@schema_cache
    end

    private

    # If schema should be resolved to snowplow iglu server
    # @param location [String]
    # @return [true, false]
    def from_snowplow?(location)
      location['iglu:com.snowplowanalytics.snowplow']
    end

    # Translate an iglu address to an actual local or remote location
    # @param location [String]
    # @param resolver [String] local or remote path to look for the schema
    # @return [String] Schema's actual location
    def resolve(location, resolver)
      location.sub(/^iglu\:/, resolver)
    end

    # Caches the schema content under its original location name
    # @param location [String]
    # @return [String] schema content
    def save_in_cache(location)
      content = if from_snowplow?(location)
        uri = URI(resolve(location, SNOWPLOW_IGLU_RESOLVER))
        Net::HTTP.get(uri)
      else
        File.read(resolve(location, Snowly.local_iglu_resolver_path))
      end
      @@schema_cache[location] = content
    end

  end
end
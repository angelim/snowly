require 'singleton'
module Snowly
  class SchemaCache
    include Singleton
    SNOWPLOW_IGLU_RESOLVER = 'http://iglucentral.com/schemas/'
    @@schema_cache = {}

    def [](location)
      @@schema_cache[location] || save_in_cache(location)
    end

    def reset_cache
      @@schema_cache = {}
    end

    def cache
      @@schema_cache
    end

    private

    def from_snowplow?(location)
      location['iglu:com.snowplowanalytics.snowplow']
    end

    def resolve(location, resolver)
      location.sub(/^iglu\:/, resolver)
    end

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
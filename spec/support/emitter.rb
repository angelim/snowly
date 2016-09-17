module Snowly
  class EmitterError < StandardError
    attr_reader :failed_events
    
    def initialize(failed_events)
      @failed_events = failed_events
    end
  end
  class Emitter
    delegate :responses, :reset_responses!, to: :emitter
    # include Singleton
    COLLECTOR_URL = 'localhost:4567'
    
    attr_reader :emitter

    def initialize(emitter_type: 'cloudfront', buffer_size: 2, thread_count: 1)
      @emitter_type = emitter_type
      @buffer_size = buffer_size
      @thread_count = thread_count
      @emitter = emitter_klass.new(COLLECTOR_URL, emitter_options)
    end

    def emitter_options
      {
        protocol: 'http',
        method: http_method,
        buffer_size: buffer_size,
        thread_count: thread_count,
        on_success: lambda { |success_count| 
          handle_on_success(success_count) 
        },
        on_failure: lambda { |success_count, failed_events|
          handle_on_failure(success_count, failed_events)
        }
      }
    end

    def self.should_handle_failure=(value)
      @@should_handle_failure = value
    end

    def emitter_klass
      cloudfront? ? SnowplowTracker::Emitter : SnowplowTracker::AsyncEmitter
    end

    def cloudfront?
      @emitter_type == 'cloudfront'
    end

    def buffer_size
      cloudfront? ? 0 : @buffer_size
    end

    def thread_count
      cloudfront? ? 1 : @thread_count
    end

    def http_method
      cloudfront? ? 'get' : 'post'
    end

    private

    def handle_on_failure(success_count, failed_events)
      puts 'failed'
    end

    def handle_on_success(success_count)
      puts 'success'
    end
  end
end

SnowplowTracker::LOGGER.level = Logger::DEBUG if Snowly.debug_mode
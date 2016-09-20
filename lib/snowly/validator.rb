require 'snowly/each_validator'
module Snowly
  class Validator
    attr_reader :validators

    def initialize(payload, batch: false)
      @validators = if batch
        payload['data'].map do |req|
          EachValidator.new(req)
        end
      else
        [ EachValidator.new(payload) ]
      end
    end

    def validate
      validators.each(&:validate)
      valid?
    end

    def valid?
      validators.all? { |v| v.valid? }
    end

    def as_hash
      validators.map(&:as_hash)
    end
  end
end
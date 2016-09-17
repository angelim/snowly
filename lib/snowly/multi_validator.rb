require 'snowly/validator'
module Snowly
  class MultiValidator
    attr_reader :validators
    
    def initialize(payload)
      @validators = payload['data'].map do |req|
        Validator.new(req)
      end
    end

    def validate
      validators.each(&:validate)
      valid?
    end

    def valid?
      validators.all? { |v| v.valid? }
    end
  end
end
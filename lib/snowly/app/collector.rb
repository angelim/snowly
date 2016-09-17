require 'erb'
require 'base64'
require 'sinatra'
require 'sinatra/reloader' if development?

module Snowly
  module App
    class Collector < Sinatra::Base
      GIF = Base64.decode64('R0lGODlhAQABAPAAAAAAAAAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw==')
      configure :development do
        register Sinatra::Reloader
      end

      def extract_content(validator)
        multi = validator.respond_to?(:validators)
        @content ||= if multi
          validator.validators.each_with_object([]) do |item, memo|
            item_request = item.request.as_hash
            memo << { event_id: item_request['event_id'], errors: item.errors, content: item_request }
          end
        else
          [{ event_id: validator.request.as_hash['event_id'], errors: validator.errors, content: validator.request.as_hash }]
        end.to_json
      end

      def handle_response(validator)
        if validator.validate
          status 200
          if params[:debug] || Snowly.debug_mode
            content = extract_content validator
            Snowly.logger.info content
            body(content)
          else
            content_type 'image/gif'
            Snowly::App::Collector::GIF
          end
        else
          status 500
          content = extract_content validator
          Snowly.logger.error content
          body (content)
        end
      end

      get '/' do
        @url = request.url.gsub(/(http|https)\:\/\//,'')[0..-2]
        @resolved_schemas = if resolver = Snowly.development_iglu_resolver_path
          Dir[File.join(resolver,"/**/*")].select{ |e| File.file? e }
        else
          nil
        end
        erb :index
      end

      get '/i' do
        content_type :json
        validator = Snowly::Validator.new request.query_string
        handle_response(validator)
      end

      post '/com.snowplowanalytics.snowplow/tp2' do
        response.headers['Allow'] = 'HEAD,GET,PUT,POST,DELETE,OPTIONS'
        response.headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept'
        response.headers['Access-Control-Allow-Credentials'] = 'true'
        response.headers['Access-Control-Allow-Origin'] = env['HTTP_ORIGIN'] || '*'
        payload = JSON.parse request.body.read
        validator = Snowly::MultiValidator.new payload
        handle_response(validator)
      end

      options '*' do
        response.headers['Allow'] = 'HEAD,GET,PUT,POST,DELETE,OPTIONS'
        response.headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept'
        response.headers['Access-Control-Allow-Credentials'] = 'true'
        response.headers['Access-Control-Allow-Origin'] = env['HTTP_ORIGIN'] || '*'
        200
      end
    end
  end
end

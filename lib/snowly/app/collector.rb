require 'thin'
require 'erb'
require 'base64'
require 'sinatra'
require 'sinatra/reloader' if development?

module Snowly
  module App
    class Collector < Sinatra::Base
      set :server, 'thin'
      GIF = Base64.decode64('R0lGODlhAQABAPAAAAAAAAAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw==')
      configure :development do
        register Sinatra::Reloader
      end

      def handle_response(validator)
        content_type :json
        if validator.validate
          status 200
          if params[:debug] || Snowly.debug_mode
            content = validator.as_hash
            Snowly.logger.info content
            body(content.to_json)
          else
            content_type 'image/gif'
            Snowly::App::Collector::GIF
          end
        else
          status 422
          content = validator.as_hash
          Snowly.logger.error content
          body (content.to_json)
        end
      end

      get '/' do
        @resolved_schemas = if resolver = Snowly.development_iglu_resolver_path
          Dir[File.join(resolver,"/**/*")].select{ |e| File.file? e }
        else
          nil
        end
        erb :index
      end

      get '/i' do
        validator = Snowly::Validator.new request.query_string
        handle_response(validator)
      end

      get '/js' do
        erb :js
      end

      post '/com.snowplowanalytics.snowplow/tp2' do
        response.headers['Allow'] = 'HEAD,GET,PUT,POST,DELETE,OPTIONS'
        response.headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept'
        response.headers['Access-Control-Allow-Credentials'] = 'true'
        response.headers['Access-Control-Allow-Origin'] = env['HTTP_ORIGIN'] || '*'
        payload = JSON.parse request.body.read
        validator = Snowly::Validator.new payload, batch: true
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

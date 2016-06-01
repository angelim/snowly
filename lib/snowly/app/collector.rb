require 'erb'
require 'base64'
require 'sinatra'
require "sinatra/reloader" if development?

module Snowly
  module App
    class Collector < Sinatra::Base
      GIF = Base64.decode64("R0lGODlhAQABAPAAAAAAAAAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw==")
      configure :development do
        register Sinatra::Reloader
      end

      get '/' do
        @url = request.url.gsub(/(http|https)\:\/\//,'')[0..-2]
        @resolved_schemas = if resolver = Snowly.local_iglu_resolver_path
          Dir[File.join(resolver,"/**/*")].select{ |e| File.file? e }
        else
          nil
        end
        erb :index
      end

      get '/i' do
        content_type :json
        validator = Snowly::Validator.new request.query_string
        if validator.validate
          status 200
          content = { content: validator.request.as_hash }.to_json
          Snowly.logger.info content
          if params[:debug] || Snowly.debug_mode
            body(content)
          else
            content_type 'image/gif'
            Snowly::App::Collector::GIF
          end
        else
          status 500
          content = { errors: validator.errors, content: validator.request.as_hash }.to_json
          Snowly.logger.error content
          body (content)
        end
      end
    end
  end
end

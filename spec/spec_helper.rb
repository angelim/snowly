# Snowplow uses questionable regex to validate the iglu location as it doesn't scape -
# Setting verbose to nil supresses a lot of warnings emmited by the Regexp class.
$VERBOSE = nil

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'snowly'
require 'snowly/app/collector'
require 'snowplow-tracker'
require 'pry'
require 'webmock/rspec'
require 'rack/test'

Dir[File.join(Dir.pwd,"spec/support/**/*.rb")].each {|f| require f}
WebMock.allow_net_connect!
TestServer.new.start_sinatra_server

module RSpecMixin
  include Rack::Test::Methods
  def app() Snowly::App::Collector end
end

RSpec.configure do |config|
  config.include RSpecMixin
  config.extend EventAssignments
end
class TestServer

  def initialize(collector_url = nil)
    @collector_url = collector_url || "http://localhost:4567"
  end

  def sinatra_startup_timeout
    @sinatra_startup_timeout || 15
  end

  def wait_until_sinatra_starts
    (sinatra_startup_timeout * 10).times do
      break if sinatra_running?
      sleep(0.1)
    end
    raise Timeout::Error, "Sinatra failed to start after #{sinatra_startup_timeout} seconds" unless sinatra_running?
  end

  def sinatra_running?
    begin
      ping_uri = URI.parse(@collector_url)
      Net::HTTP.get(ping_uri)
      true
    rescue
      false
    end
  end

  def start_sinatra_server
    Snowly.development_iglu_resolver_path = File.expand_path("../../fixtures", __FILE__)+"/"
    WebMock.allow_net_connect!
    unless sinatra_running?
      pid = fork do
        Snowly.debug_mode = true
        Snowly::App::Collector.run!
      end

      at_exit do
        WebMock.disable_net_connect!
        Process.kill("TERM", pid)
      end

      wait_until_sinatra_starts
    end
  end
end
SnowplowTracker::Emitter.class_eval do
  attr_reader :responses  
  alias_method :original_http_get, :http_get
  alias_method :original_http_post, :http_post

  def reset_responses!
    @responses = []
  end
  
  def http_get(*args)
    original_http_get(*args).tap do |response|
      @responses ||= []
      @responses << response
    end
  end
  def http_post(*args)
    response = original_http_post(*args).tap do |response|
      @responses ||= []
      @responses << response
    end
  end
end
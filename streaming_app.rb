require 'webmachine'
require 'reel'
require 'json'

class LiveResource < Webmachine::Resource
  def initialize
    set_headers
  end

  def set_headers
    response.headers['Connection']    ||= 'keep-alive'
    response.headers['Cache-Control'] ||= 'no-cache'
  end

  def allowed_methods
    %W[GET]
  end

  def content_types_provided
    [['text/event-stream', :render_event]]
  end

  def render_event
    Fiber.new do
      data = JSON.generate(hello: 'world')
      10.times do |id|
        Fiber.yield "id: #{id}\nevent: hello\ndata: #{data}\n\n"
        sleep 2
      end
    end
  end
end

app = Webmachine::Application.new
app.routes do
  add ['live'], LiveResource
end
app.configure do |config|
  config.adapter = :Reel
end
app.run

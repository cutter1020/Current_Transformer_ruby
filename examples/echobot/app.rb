require 'sinatra'   # gem 'sinatra'
require 'line/bot'  # gem 'line-bot-api'
require 'mqtt'
require 'rubygems'

def client
  @client ||= Line::Bot::Client.new { |config|
    config.channel_id = "Ub5ea85368411eeeddb86dde7d53c43ae"
    config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
    config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
  }
end

post '/callback' do
  request.body.rewind
  body = request.body.read
  MQTT::Client.connect('broker.emqx.io',1883) do |c|
    c.publish('3ZeDnU$/', "test123")
  end
  MQTT::Client.connect('broker.emqx.io') do |c|
    c.publish('3ZeDnU$/', body)
  end
  json_body = JSON.parse(body)

  if json_body['ESP']
    message = {
        type: 'text',
        text: json_body['ESP']
      }
      client.push_message("C9c7c2c3dbf0d0b116c86bc6af8e6c73e", message)
  else
    events = client.parse_events_from(body)
    events.each do |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          message = {
            type: 'text',
            text: event.message['text']
          }
          #client.reply_message(event['replyToken'], message)
          #client.push_message("U97f1978ea01a7f94867501b8a66b6038", message)
          #client
         # Publish example
          MQTT::Client.connect('broker.emqx.io') do |c|
            c.publish('3ZeDnU$/', event.message['text'])
          end
        end
      end
    end
  end
  #signature = request.env['HTTP_X_LINE_SIGNATURE']
  #unless client.validate_signature(body, signature)
  #  halt 400, {'Content-Type' => 'text/plain'}, 'Bad Request'
  #end
  
  #events = client.parse_events_from(body)
  "OK"
end

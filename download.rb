require 'slack'
require 'mongo'

Slack.configure do |config|
  config.token = ENV['SLACK_HISTORY_DOWNLOADER']
end

client = Slack::Client.new
channel = client.channels_list['channels'].map { |i| [i['name'], i['id']] }.to_h
history = client.channels_history(channel: channel['general'])

messages = []
if history['ok']
  messages = history['messages']
else
  puts 'fail to get history'
  exit(0)
end

client = Mongo::Client.new 'mongodb://127.0.0.1:27017/slack'
collection = client[:history]

new_messages = []
stored_timestamps = collection.find.sort(ts: -1)
                              .projection(ts: 1, _id: 0).map { |i| i['ts'] }

def exist?(message, stored_timestamps)
  stored_timestamps.each do |stored_timestamp|
    return true if message['ts'] == stored_timestamp
  end
  false
end

messages.each do |message|
  new_messages << message unless exist?(message, stored_timestamps)
end

collection.insert_many new_messages
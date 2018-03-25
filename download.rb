require 'slack'
require 'mongo'

Slack.configure do |config|
  config.token = ENV['SLACK_HISTORY_DOWNLOADER']
end

client = Slack::Client.new
channel = client.channels_list['channels'].map { |i| [i['name'], i['id']] }.to_h
history = client.channels_history(channel: channel['general'])
if history['ok']
  messages = history['messages']
else
  puts 'fail to get history'
  exit(0)
end

client = Mongo::Client.new 'mongodb://127.0.0.1:27017/slack'
collection = client[:history]
collection.insert_many messages
require 'mongo'
require './client'

slack_client = Client.new
messages = slack_client.get_channel_history('general')

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
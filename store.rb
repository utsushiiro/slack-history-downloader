require 'mongo'

class Store
  def initialize
    @client = Mongo::Client.new 'mongodb://127.0.0.1:27017/slack'
    @history_collection = @client[:history]
  end

  def update_channel_history(history)
    collection_name = "channel-history:#{history[:channel_name]}"
    puts "update #{collection_name}"
    collection = @client[collection_name.to_s]
    collection.insert_many(get_new_messages(collection, history))
  end

  def get_new_messages(collection, history)
    new_messages = []
    stored_timestamps = collection.find
                          .sort(ts: -1)
                          .projection(ts: 1, _id: 0)
                          .map {|i| i['ts'] }
    history[:messages].each do |message|
      new_messages << message unless message_stored?(message, stored_timestamps)
    end
    new_messages
  end

  def message_stored?(message, stored_timestamps)
    stored_timestamps.each do |stored_timestamp|
      return true if message['ts'] == stored_timestamp
    end
    false
  end
end
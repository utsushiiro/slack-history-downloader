require 'mongo'

class Store
  def initialize(logger)
    @logger = logger
    @client = Mongo::Client.new 'mongodb://127.0.0.1:27017/slack'
    @history_collection = @client[:history]
  end

  def update_channel_history(history)
    collection_name = "channel-history:#{history[:channel_name]}"
    @logger.info("update #{collection_name}")
    collection = @client[collection_name.to_s]
    collection.insert_many(get_not_stored_messages(collection, history))
  end

  def get_not_stored_messages(collection, history)
    not_stored_messages = []
    stored_timestamps = collection.find
                          .sort(ts: -1)
                          .projection(ts: 1, _id: 0)
                          .map {|i| i['ts'] }
    history[:messages].each do |message|
      not_stored_messages << message unless stored_timestamps.include?(message['ts'])
    end
    not_stored_messages
  end
end
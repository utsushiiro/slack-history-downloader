require 'mongo'
require './client'
require './store'

logger = Logger.new(STDOUT)
slack_client = Client.new logger
store = Store.new logger

all_channel_names = slack_client.channel_list.map {|i| i['name'] }
all_channel_names.each do |channel_name|
  history = slack_client.get_channel_history(channel_name)
  store.update_channel_history(history)
end
require 'mongo'
require './client'
require './store'

slack_client = Client.new
store = Store.new

all_channel_names = slack_client.channel_list.map {|i| i['name'] }
all_channel_names.each do |channel_name|
  history = slack_client.get_channel_history(channel_name)
  store.update_channel_history(history)
end
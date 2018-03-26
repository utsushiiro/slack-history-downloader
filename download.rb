require 'mongo'
require './client'
require './store'

slack_client = Client.new
history = slack_client.get_channel_history('general')

store = Store.new
store.update_channel_history(history)
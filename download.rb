require 'mongo'
require './client'
require './store'
require 'rufus-scheduler'

logger = Logger.new(STDOUT)
scheduler = Rufus::Scheduler.new
slack_client = Client.new logger
store = Store.new logger

scheduler.every '1h', first: :now do
  logger.info 'start downloading'
  all_channel_names = slack_client.channel_list.map {|i| i['name'] }
  all_channel_names.each do |channel_name|
    history = slack_client.get_channel_history(channel_name)
    store.update_channel_history(history)
  end
  logger.info 'finished downloading'
end

scheduler.join
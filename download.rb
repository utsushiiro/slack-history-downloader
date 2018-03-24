require 'slack'

Slack.configure do |config|
  config.token = ENV['SLACK_HISTORY_DOWNLOADER']
end

client = Slack::Client.new
channel = client.channels_list['channels'].map { |i| [i['name'], i['id']] }.to_h
history = client.channels_history(channel: channel['general'])
puts history
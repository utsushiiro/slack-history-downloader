require 'slack'

class Client
  def initialize
    @client = Slack::Client.new token: ENV['SLACK_HISTORY_DOWNLOADER']
    @channel_list = @client.channels_list['channels']
    @channel_name_to_id_table = @channel_list.map { |i| [i['name'], i['id']] }.to_h
  end

  def get_channel_history(channel_name)
    channel_id = @channel_name_to_id_table[channel_name]
    history = @client.channels_history(channel: channel_id)

    unless history['ok']
      puts 'fail to get history'
      exit(0)
    end

    history['messages']
  end
end
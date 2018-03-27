require 'slack'

class Client
  HISTORY_PAGE_SIZE = 1000
  MAX_HISTORY_PAGE_NUM = 10

  def initialize
    @client = Slack::Client.new token: ENV['SLACK_HISTORY_DOWNLOADER']
    @channel_list = @client.channels_list['channels']
    @channel_name_to_id_table = @channel_list.map { |i| [i['name'], i['id']] }.to_h
  end

  def get_channel_history(channel_name)
    channel_id = @channel_name_to_id_table[channel_name]
    history = @client.channels_history(channel: channel_id, count: HISTORY_PAGE_SIZE)
    message_stack = history['messages']
    page = 1

    unless history['ok']
      puts 'fail to get history'
      exit(0)
    end

    while history['has_more']
      break if page > MAX_HISTORY_PAGE_NUM

      oldest = history['messages'][0]['ts']
      history['messages'].each do |message|
        ts = message['ts']
        oldest = ts if oldest > ts
      end

      history = @client.channels_history(channel: channel_id, latest: oldest, count: HISTORY_PAGE_SIZE)
      message_stack.push(history['messages'])
      page += 1
    end

    message_stack
  end
end
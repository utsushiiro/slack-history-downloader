require 'slack'

class Client
  HISTORY_PAGE_SIZE = 1000
  MAX_HISTORY_PAGE_NUM = 10

  attr_reader :channel_list

  def initialize(logger)
    @logger = logger
    @client = Slack::Client.new token: ENV['SLACK_HISTORY_DOWNLOADER']
    @channel_list = @client.channels_list['channels']
    @channel_name_to_id_table = @channel_list.map {|i| [i['name'], i['id']] }.to_h
  end

  def get_channel_history(channel_name)
    channel_id = @channel_name_to_id_table[channel_name]
    latest = Time.now.to_f.to_s
    page = 0
    message_stack = []

    loop do
      history = @client.channels_history(channel: channel_id, latest: latest, count: HISTORY_PAGE_SIZE)
      check_history_response(history)

      latest = history['messages'].last['ts']
      page += 1
      message_stack << history['messages']

      break unless history['has_more'] && page < MAX_HISTORY_PAGE_NUM
    end

    { channel_name: channel_name, messages: message_stack.flatten }
  end

  def check_history_response(history)
    return if history['ok']
    @logger.error 'fail to get channel history'
    warn 'fail to get history'
    exit(0)
  end
end
class SaveCountsPersistentJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # get all applications in MySQL database
    Application.find_each do |application|
      # check if present in redis or not
      if $redis.get("application_token:#{application.token}/chats_count").present?
        # if present then get the chat count from redis and update it in MySQL database
        application.chats_count = $redis.get("application_token:#{application.token}/chats_count").to_i
        application.save!
      end
    end

    # get all chats in MySQL database
    Chat.find_each do |chat|
      # check if present in redis or not
      if $redis.get("application_token:#{chat.application.token}/chat_number:#{chat.number}/messages_count").present?
        # if present then get the message count from redis and update it in MySQL database
        chat.messages_count = $redis.get("application_token:#{chat.application.token}/chat_number:#{chat.number}/messages_count").to_i
        chat.save!
      end
    end

  end
end

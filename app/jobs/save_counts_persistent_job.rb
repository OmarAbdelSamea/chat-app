class SaveCountsPersistentJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Application.find_each do |application|
      if $redis.get("application_token:#{application.token}/chats_count").present?
        application.chats_count = $redis.get("application_token:#{application.token}/chats_count").to_i
        application.save!
      end
    end

    Chat.find_each do |chat|
      if $redis.get("application_token:#{chat.application.token}/chat_number:#{chat.number}/messages_count").present?
        chat.messages_count = $redis.get("application_token:#{chat.application.token}/chat_number:#{chat.number}/messages_count").to_i
        chat.save!
      end
    end

  end
end

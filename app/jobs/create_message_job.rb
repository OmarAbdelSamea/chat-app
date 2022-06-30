class CreateMessageJob < ApplicationJob
  queue_as :default

  def perform(*args)
    chat = args[0]
    message_params = args[1]
    message_number = args[2]
    chat.with_lock do
      # sleep 2 for testing purposes
      chat.messages.create!(message_params)
      puts "Message saved to db #{chat.messages.last}"
  
      increment_messages_count(chat, message_number)
      puts "Message count incremented in Redis#{message_number}"
    end
  end

  def increment_messages_count(chat, messages_count)
    $redis.set("application_token:#{chat.application.token}/chat_number:#{chat.number}/messages_count", messages_count)
  end
end

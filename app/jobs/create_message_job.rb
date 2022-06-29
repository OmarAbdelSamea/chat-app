class CreateMessageJob < ApplicationJob
  queue_as :default

  def perform(*args)
    chat = args[0]
    chat.with_lock do
      message_params = args[1]
      # sleep 2 for testing purposes
      chat.messages.create!(message_params)
      puts "Message saved to db #{chat.messages.last}"
  
      increment_messages_count(chat)
      puts "Message count incremented #{chat.messages_count}"
    end
  end

  def increment_messages_count(chat)
    chat.messages_count += 1
    chat.save
  end
end

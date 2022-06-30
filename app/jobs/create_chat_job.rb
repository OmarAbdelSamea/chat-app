class CreateChatJob < ApplicationJob
  queue_as :default

  def perform(*args)
    application = args[0]
    chat_number = args[1]
    puts "application: #{application.inspect}"
    application.with_lock do
      # sleep 2 # for testing purposes
      application.chats.create!()
      puts "Chat saved to db #{application.chats.last}"
  
      increment_chats_count(application.token, chat_number)
      puts "Chat count incremented in Redis #{chat_number}"
    end
  end

  def increment_chats_count(application_token, chats_count)
    $redis.set("application_token:#{application_token}/chats_count", chats_count)
  end
end

class CreateChatJob < ApplicationJob
  queue_as :default

  def perform(*args)
    application = args[0]
    application.with_lock do
      # sleep 2 for testing purposes
      application.chats.create!()
      puts "Chat saved to db #{application.chats.last}"
  
      increment_chats_count(application)
      puts "Chat count incremented #{application.chats_count}"
    end
  end

  def increment_chats_count(application)
    application.chats_count += 1
    application.save
  end
end

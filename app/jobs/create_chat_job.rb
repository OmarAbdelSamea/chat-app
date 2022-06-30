class CreateChatJob < ApplicationJob
  queue_as :default

  def perform(*args)
    application = args[0]
    chat_number = args[1]
    puts "application: #{application.inspect}"
    application.with_lock do
      # sleep 2 # for testing purposes
      application.chats.create!(number: chat_number)
      puts "Chat saved to db #{application.chats.last}"
    end
  end

end

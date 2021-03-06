class CreateChatJob < ApplicationJob
  queue_as :default

  def perform(*args)
    application = args[0]
    chat_number = args[1]
    # sleep 2 # for testing purposes
    application.chats.create!(number: chat_number)
  end
end

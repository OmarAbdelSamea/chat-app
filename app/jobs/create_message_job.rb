class CreateMessageJob < ApplicationJob
  queue_as :default

  def perform(*args)
    chat = args[0]
    message_params = args[1]
    message_number = args[2]
    # sleep 2 for testing purposes
    chat.messages.create!(number: message_number, content: message_params)
    puts "Message saved to db #{chat.messages.last}"
  end
end

class UpdateMessageJob < ApplicationJob
  queue_as :default

  def perform(*args)
    message = args[0]
    message_params = args[1]
    message.with_lock do
      message.update!(message_params)
      puts "Message updated in db #{message.content}"
    end
  end
end

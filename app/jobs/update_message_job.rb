class UpdateMessageJob < ApplicationJob
  queue_as :default

  def perform(*args)
    message = args[0]
    message_params = args[1]
    # pessimistic locking in MySQL database until the record is updated
    message.with_lock do
      message.update!(message_params)
    end
  end
end

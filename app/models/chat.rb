class Chat < ApplicationRecord
  has_many :messages, dependent: :destroy
  belongs_to :application
  before_create :populate_scoped_number

  def populate_scoped_number
    if $redis.get("application_token:#{application.token}/chats_count").present?
      self.number = $redis.get("application_token:#{application.token}/chats_count").to_i + 1
    else
      $redis.set("application_token:#{application.token}/chats_count", application.chats_count)
      self.number = application.chats_count + 1
    end
  end
end

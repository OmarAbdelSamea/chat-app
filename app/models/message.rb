require 'elasticsearch/model'

class Message < ApplicationRecord
  belongs_to :chat
  validates_presence_of :content
  before_create :populate_scoped_number

  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  def populate_scoped_number
    if $redis.get("application_token:#{chat.application.token}/chat_number:#{chat.number}/messages_count").present?
      self.number = $redis.get("application_token:#{chat.application.token}/chat_number:#{chat.number}/messages_count").to_i + 1
    else
      $redis.set("application_token:#{chat.application.token}/chat_number:#{chat.number}/messages_count", chat.messages_count)
      self.number = chat.messages_count + 1
    end
  end
end

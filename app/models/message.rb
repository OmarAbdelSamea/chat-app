require 'elasticsearch/model'

class Message < ApplicationRecord
  belongs_to :chat
  validates_presence_of :content
  before_create :populate_scoped_number

  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  def populate_scoped_number
    self.number = chat.messages.last.present? ? chat.messages.last.number + 1 : 1
  end

end

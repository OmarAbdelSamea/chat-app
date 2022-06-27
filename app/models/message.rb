class Message < ApplicationRecord
  belongs_to :chat
  validates_presence_of :content
  before_create :populate_scoped_number

  def populate_scoped_number
    if chat.messages.last.present?
      self.number = chat.messages.last.number + 1     
    else
      self.number = 1
    end
  end
end

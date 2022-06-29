class Chat < ApplicationRecord
  has_many :messages, dependent: :destroy
  belongs_to :application
  before_create :populate_scoped_number

  def populate_scoped_number
    self.number = application.chats_number + 1
  end
end

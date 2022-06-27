class Chat < ApplicationRecord
  has_many :messages, dependent: :destroy
  belongs_to :application
  before_create :populate_scoped_number, :increment_chats_count

  def populate_scoped_number
    if application.chats.last.present?
      self.number = application.chats.last.number + 1     
    else
      self.number = 1
    end
  end

  def increment_chats_count
    application.chats_count += 1
    application.save
  end
end

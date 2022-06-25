class Chat < ApplicationRecord
  belongs_to :application

  validates_presence_of :number
end

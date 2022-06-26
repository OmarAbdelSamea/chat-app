class Application < ApplicationRecord
    has_many :chats, dependent: :destroy
    validates_presence_of :name
    has_secure_token 
end

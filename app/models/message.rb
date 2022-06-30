require 'elasticsearch/model'

class Message < ApplicationRecord
  belongs_to :chat
  validates_presence_of :content

  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
end

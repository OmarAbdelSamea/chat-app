require 'rails_helper'

RSpec.describe Application, type: :model do

  # basic test
  # one to many relation with Chat
  it { should have_many(:chats).dependent(:destroy) }

  it { should validate_presence_of(:name) }
end

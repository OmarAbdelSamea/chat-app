require 'rails_helper'

RSpec.describe Message, type: :model do
  it { should belong_to(:chat) }

  it { should validate_presence_of(:content) }

end

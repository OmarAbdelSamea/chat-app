require 'rails_helper'

RSpec.describe Chat, type: :model do
  it { should belong_to(:application) }

end

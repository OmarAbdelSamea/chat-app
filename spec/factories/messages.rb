FactoryBot.define do
  factory :message do
    number { 1 }
    content { Faker::Lorem.paragraph }
    chat { 0 }
  end
end

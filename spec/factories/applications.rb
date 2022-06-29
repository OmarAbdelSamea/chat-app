require 'faker'

FactoryBot.define do
  factory :application do
    token { SecureRandom.hex(24)}
    name { Faker::Superhero.name }
    chats_count { 1 }
  end
end

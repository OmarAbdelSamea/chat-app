require 'faker'

FactoryBot.define do
  factory :chat do
    number { 1 }
    name { Faker::Superhero.name }
    messages_count { 1 }
    application { 0 }
  end
end

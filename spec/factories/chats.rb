FactoryBot.define do
  factory :chat do
    number { 1 }
    name { "MyString" }
    messages_count { 1 }
    application { nil }
  end
end

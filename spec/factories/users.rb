FactoryBot.define do

  factory :user do
    # company_id (required)

    sequence(:name) { |n| "user_#{n + 1}" }
    sequence(:email) { |n| "user#{n + 1}@email.com" }
    password '123456'
    vehicle true
    color { Faker::Color.hex_color }
  end

end

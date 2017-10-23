FactoryGirl.define do

  factory :user do
    # company_id (required)

    sequence(:sync_user) { |n| "user_#{n + 1}" }
    sequence(:email) { |n| "user#{n + 1}@email.com" }
    password 'password'
    vehicle true
  end

end

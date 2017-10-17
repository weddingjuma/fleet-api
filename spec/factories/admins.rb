FactoryGirl.define do

  factory :admin do
    sequence(:name) { |n| "admin_#{n + 1}" }
    sequence(:email) { |n| "admin#{n + 1}@email.com" }
    password 'password'
  end

end

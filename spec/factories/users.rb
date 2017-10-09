FactoryGirl.define do

  factory :user do
    sequence(:user) { |n| "user name #{n + 1}" }
  end

end

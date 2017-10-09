FactoryGirl.define do

  factory :company do
    sequence(:name) { |n| "name #{n + 1}" }
  end

end

FactoryBot.define do

  factory :company do
    sequence(:name) { |n| "name #{n + 1}" }
    default_mission_status_type_id 1
  end

end

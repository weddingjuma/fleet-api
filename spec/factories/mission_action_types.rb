FactoryBot.define do

  factory :mission_action_type do
    # company_id (required)
    # previous_mission_status_type_id (required)
    # next_mission_status_type_id (required)

    label { Faker::Lorem.word }
    group { Faker::Lorem.word }
  end

end

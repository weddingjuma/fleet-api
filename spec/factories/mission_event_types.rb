FactoryBot.define do

  factory :mission_event_type do
    # company_id (required)
    # mission_action_type (required)

    group { Faker::Lorem.word }
    context 'server'
  end

end

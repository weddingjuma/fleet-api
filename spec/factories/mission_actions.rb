FactoryBot.define do

  factory :mission_action do
    # company_id (required)
    # mission_id (required)
    # mission_action_type_id (required)

    date { Faker::Time.forward(Random.rand(0..3)).strftime('%FT%T.%L%:z') }
    comment { Faker::Lorem.sentence(3) }
    action_location { { lat: Random.rand(43.0..50.0), lon: Random.rand(-2.0..6.0) } }
  end

end

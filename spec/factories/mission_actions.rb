FactoryBot.define do

  factory :mission_action do
    # company_id (required)
    # mission_id (required)
    # mission_action_type_id (required)

    date { Faker::Time.forward(Random.rand(0..3)).strftime('%FT%T.%L%:z') }
    comment { Faker::Lorem.sentence(3) }
  end

end

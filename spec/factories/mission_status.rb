FactoryBot.define do

  factory :mission_status do
    # company_id (required)
    # mission_id (required)
    # mission_status_type_id (required)

    date { Faker::Time.forward(Random.rand(0..3)).strftime('%FT%T.%L%:z') }
    description { Faker::Lorem.sentence(3) }
  end

end

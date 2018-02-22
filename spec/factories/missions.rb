FactoryBot.define do

  factory :mission do
    # company_id (required)
    # user_id (required)
    # sync_user (required - automatic)

    sequence(:name) { |n| "mission name #{n + 1}" }
    sequence(:external_ref) { |n| "ref_#{n + 1}" }
    date { Faker::Time.forward(Random.rand(0..3)).strftime('%FT%T.%L%:z') }
    location {
      {
        lat: Random.rand(43.0..50.0),
        lon: Random.rand(-2.0..6.0)
      }
    }
    address {
      {
        city: Faker::Address.city,
        country: Faker::Address.country,
        detail: Faker::Address.secondary_address,
        postalcode: Faker::Address.postcode,
        state: Faker::Address.state,
        street: Faker::Address.street_address
      }
    }
    comment { Faker::Lorem.sentence(3) }
    phone '0600000000'
    duration { Random.rand(1..300) }
    mission_type 'mission'
  end

end

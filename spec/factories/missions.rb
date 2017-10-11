FactoryGirl.define do

  factory :mission do
    # company_id (required)

    sequence(:name) { |n| "mission name #{n + 1}" }
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
    date { Faker::Time.backward(30).iso8601 }
    location {
      {
        lat: Random.rand(43.0..50.0),
        lon: Random.rand(-2.0..6.0)
      }
    }
    phone '0600000000'
    duration { Random.rand(1..300) }
  end

end

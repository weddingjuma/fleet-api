FactoryGirl.define do

  factory :track do
    # company_id (required)
    # user_id (required)
    # sync_user (required - automatic)

    date { Faker::Time.forward(1).strftime('%FT%T.%L%:z') }
    locationDetails {
      Array.new(Random.rand(1..5)) do |i|
        {
          lat: Random.rand(43.0..50.0),
          lon: Random.rand(-2.0..6.0),
          date: Faker::Time.forward(1).strftime('%FT%T.%L%:z'),
          accuracy: Random.rand(1..10),
          speed: Random.rand(1..500),
          bearing: Random.rand(1..360),
          elevation: Random.rand(1..3_000),
          signalStrength: Random.rand(1..10_000),
          cid: Random.rand(1..10),
          lac: Random.rand(1..10),
          mcc: Random.rand(1..1_000),
          mnc: Random.rand(1..1_000),
        }
      end
    }
  end

end

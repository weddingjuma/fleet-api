FactoryBot.define do

  factory :route do
    # company_id (required)
    # user_id (required)
    # sync_user (required - automatic)

    sequence(:name) { |n| "route name #{n + 1}" }
    sequence(:external_ref) { |n| "ref_route_#{n + 1}" }
    date { Faker::Time.forward(Random.rand(0..3)).strftime('%FT%T.%L%:z') }
  end

end

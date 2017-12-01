FactoryBot.define do

  factory :mission_placeholder do
    # company_id (required)
    # sync_user (required)

    date { Faker::Time.forward(1).strftime('%F') }
  end

end

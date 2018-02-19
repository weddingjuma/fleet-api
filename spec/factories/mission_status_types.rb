FactoryBot.define do

  factory :mission_status_type do
    # company_id (required)

    reference { Faker::Lorem.word }
    label { Faker::Lorem.word }
    color { Faker::Color.hex_color }
  end

end

FactoryBot.define do

  factory :meta_info do
    server_version { Faker::Number.number(2) }
    minimal_client_version { Faker::Number.number(2) }
  end

end

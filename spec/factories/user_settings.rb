FactoryBot.define do

  factory :user_settings do
    # company_id (required)
    # user_id (required)
    # sync_user (required - automatic)

    data_connection true
    automatic_data_update true
    map_current_position true
    night_mode 'automatic'
  end

end

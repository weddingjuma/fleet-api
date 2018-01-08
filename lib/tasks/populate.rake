namespace :mapotempo_fleet do

  # Example:
  # rails mapotempo_fleet:populate
  desc 'Reset the database, migrate the database, initialize with the seed data and reindex models for search'
  task :populate, [] => :environment do |_task, _args|
    `spring stop` if Rails.env.development?

    ### Prerequisite
    # A bucket for development exists (fleet-dev for instance)
    # A sync user (sync-user for instance) is already defined with admin permissions to the previous bucket (in sync-gateway-config.json file)
    # A sync function for Sync Gateway is declared

    # Create Couchbase views for indexing
    Admin.ensure_design_document!
    Company.ensure_design_document!
    User.ensure_design_document!
    Mission.ensure_design_document!
    MissionStatus.ensure_design_document!
    MissionStatusType.ensure_design_document!
    MissionStatusAction.ensure_design_document!
    MissionsPlaceholder.ensure_design_document!
    UserCurrentLocation.ensure_design_document!
    UserSettings.ensure_design_document!
    UserTrack.ensure_design_document!

    # Company
    company = FactoryBot.create(:company, name: 'default')

    # Users for connexion
    FactoryBot.create(:user, company: company, sync_user: 'default', password: '123456', email: 'fleet@mapotempo.com', vehicle: false)

    # Driver users for testing purpose
    driver_roles = %w[mission.creating mission.updating mission.deleting mission_status.creating mission_status.updating mission_status.deleting user_settings.creating user_settings.updating user_current_location.creating user_current_location.updating user_track.creating user_track.updating]
    driver_1 = FactoryBot.create(:user, company: company, sync_user: 'driver1', password: '123456', email: 'driver1@mapotempo.com', vehicle: true, roles: driver_roles)
    driver_2 = FactoryBot.create(:user, company: company, sync_user: 'driver2', password: '123456', email: 'driver2@mapotempo.com', vehicle: true, roles: driver_roles)
    driver_3 = FactoryBot.create(:user, company: company, sync_user: 'driver3', password: '123456', email: 'driver3@mapotempo.com', vehicle: true, roles: driver_roles)

    # Mission status types
    todo_status_type = FactoryBot.create(:mission_status_type, company: company, label: 'To do', color: '#ff0000', svg_path: 'M 29.62266,0 C 21.6892,0 14.3112,3.06885 8.69003,8.69003 3.06885,14.3112 0,21.6892 0,29.62266 l 0,68.76068 c 0,7.93347 3.06885,15.30546 8.69003,20.92663 C 14.3112,124.93115 21.6892,128 29.62266,128 l 68.76065,0 c 7.93347,0 15.30549,-3.06885 20.92666,-8.69003 C 124.93115,113.6888 128,106.31681 128,98.38334 l 0,-68.76068 C 128,21.6892 124.93115,14.3112 119.30997,8.69003 113.6888,3.06885 106.31678,0 98.38331,0 L 29.62266,0 Z m 0,22.21849 68.76065,0 c 2.25524,0 3.59459,0.55036 5.2212,2.177 1.62664,1.62664 2.18297,2.97193 2.18297,5.22717 l 0,68.76068 c 0,2.25524 -0.55633,3.59456 -2.18297,5.2212 -1.62661,1.62661 -2.96593,2.18297 -5.2212,2.18297 l -68.76065,0 c -2.25527,0 -3.60056,-0.55636 -5.2272,-2.18297 -1.62664,-1.62664 -2.17697,-2.96596 -2.17697,-5.2212 l 0,-68.76068 c 0,-2.25524 0.55033,-3.60053 2.17697,-5.22717 1.62664,-1.62664 2.97196,-2.177 5.2272,-2.177 z')
    in_progress_status_type = FactoryBot.create(:mission_status_type, company: company, label: 'In progress', color: '#66ff33', svg_path: 'm 90.66669,64 q 0,2.74999 -2.25001,4.33335 L 51.08336,95 Q 48.50002,96.91668 45.58337,95.41667 42.66669,94 42.66669,90.66668 l 0,-53.333328 q 0,-3.33335 2.91668,-4.75002 2.91665,-1.49998 5.49999,0.41667 L 88.41668,59.66668 Q 90.66669,61.25001 90.66669,64 Z m 15.99999,40 0,-80 q 0,-1.16666 -0.75,-1.91665 -0.74999,-0.75 -1.91668,-0.75 l -80,0 q -1.16666,0 -1.91665,0.75 -0.75,0.74999 -0.75,1.91665 l 0,80 q 0,1.16666 0.75,1.91668 0.74999,0.75 1.91665,0.75 l 80,0 q 1.16669,0 1.91668,-0.75 0.75,-0.75002 0.75,-1.91668 z M 128,24 l 0,80 q 0,9.91668 -7.04166,16.95834 Q 113.91668,128 104,128 l -80,0 Q 14.08335,128 7.04169,120.95834 0,113.91668 0,104 L 0,24 Q 0,14.08335 7.04169,7.04166 14.08335,0 24,0 l 80,0 q 9.91668,0 16.95834,7.04166 Q 128,14.08335 128,24 Z')
    completed_status_type = FactoryBot.create(:mission_status_type, company: company, label: 'Completed', color: '#0000ff', svg_path: 'M 29.61804,0 C 21.68421,0 14.30587,3.069 8.68443,8.6904 3.06302,14.3118 0,21.6902 0,29.624 l 0,68.7639 c 0,7.9338 3.06302,15.3062 8.68443,20.9276 5.62144,5.6215 12.99978,8.6904 20.93361,8.6904 l 68.76389,0 c 7.93383,0 15.31217,-3.0689 20.93361,-8.6904 C 124.93698,113.6941 128,106.3217 128,98.3879 l 0,-68.7639 c -3e-5,-7.9338 -3.06302,-15.3122 -8.68446,-20.9336 C 113.6941,3.069 106.31576,0 98.38193,0 L 29.61804,0 Z m 0,22.2195 68.76389,0 c 2.25534,0 3.6007,0.5504 5.22742,2.1771 1.62671,1.6267 2.1771,2.9721 2.1771,5.2274 l 0,68.7639 c 0,2.2553 -0.55039,3.5947 -2.1771,5.2215 -1.62672,1.6266 -2.97208,2.183 -5.22742,2.183 l -68.76389,0 c -2.25534,0 -3.59473,-0.5564 -5.22145,-2.183 -1.62668,-1.6268 -2.18307,-2.9662 -2.18307,-5.2215 l 0,-68.7639 c 0,-2.2553 0.55639,-3.6007 2.18307,-5.2274 1.62672,-1.6267 2.96611,-2.1771 5.22145,-2.1771 z m 71.62725,24.3881 q 0,1.9223 -1.3456,3.2679 l -34.79352,34.7935 -6.5358,6.5359 q -1.3456,1.3456 -3.26789,1.3456 -1.92232,0 -3.26792,-1.3456 L 45.49878,84.669 28.10202,67.2723 q -1.34563,-1.3456 -1.34563,-3.2679 0,-1.9223 1.34563,-3.2679 l 6.53578,-6.5358 q 1.34563,-1.3456 3.26792,-1.3456 1.92229,0 3.26789,1.3456 l 14.12887,14.1769 31.5256,-31.5737 q 1.3456,-1.3456 3.26792,-1.3456 1.92228,0 3.26788,1.3456 l 6.53581,6.5359 q 1.3456,1.3456 1.3456,3.2678 z')
    uncompleted_status_type = FactoryBot.create(:mission_status_type, company: company, label: 'Uncompleted', color: '#cc0099', svg_path: 'm 95.20107,83.0195 q 0,2.101 -1.47075,3.5718 l -7.14377,7.1438 q -1.47078,1.4708 -3.57191,1.4708 -2.10109,0 -3.57188,-1.4708 L 63.99962,78.292 48.55647,93.7351 q -1.47078,1.4708 -3.57188,1.4708 -2.10112,0 -3.57191,-1.4708 l -7.14376,-7.1438 q -1.47076,-1.4708 -1.47076,-3.5718 0,-2.1012 1.47076,-3.5719 L 49.71209,64.0044 34.26892,48.5613 q -1.47076,-1.4708 -1.47076,-3.5719 0,-2.1011 1.47076,-3.5719 l 7.14376,-7.1438 q 1.47079,-1.4708 3.57191,-1.4708 2.1011,0 3.57188,1.4708 L 63.99962,49.7169 79.44276,34.2737 q 1.47079,-1.4708 3.57188,-1.4708 2.10113,0 3.57191,1.4708 l 7.14377,7.1438 q 1.47075,1.4708 1.47075,3.5719 0,2.1011 -1.47075,3.5719 L 78.28714,64.0044 93.73032,79.4476 q 1.47075,1.4707 1.47075,3.5719 z M 29.61804,0 C 21.68421,0 14.3059,3.069 8.68446,8.6904 3.06302,14.3118 0,21.6902 0,29.624 l 0,68.7639 c 0,7.9338 3.06302,15.3062 8.68446,20.9276 5.62144,5.6215 12.99975,8.6904 20.93358,8.6904 l 68.76389,0 c 7.93383,0 15.31217,-3.0689 20.93361,-8.6904 C 124.93698,113.6941 128,106.3217 128,98.3879 L 128,29.624 C 128,21.6902 124.93698,14.3118 119.31554,8.6904 113.6941,3.069 106.31576,0 98.38193,0 L 29.61804,0 Z m 0,22.2195 68.76389,0 c 2.25534,0 3.59473,0.5504 5.22144,2.1771 1.62669,1.6267 2.18308,2.9721 2.18308,5.2274 l 0,68.7639 c 0,2.2553 -0.55639,3.5948 -2.18308,5.2215 -1.62671,1.6267 -2.9661,2.183 -5.22144,2.183 l -68.76389,0 c -2.25531,0 -3.6007,-0.5563 -5.22742,-2.183 -1.62668,-1.6267 -2.1771,-2.9662 -2.1771,-5.2215 l 0,-68.7639 c 0,-2.2553 0.55042,-3.6007 2.1771,-5.2274 1.62672,-1.6267 2.97211,-2.1771 5.22742,-2.1771 z')

    # Associate a default status type to company for new missions
    company.update_attribute(:default_mission_status_type_id, todo_status_type.id)

    # Mission status actions
    # to do => in progress
    # to do => uncompleted
    FactoryBot.create(:mission_status_action, company: company, previous_mission_status_type: todo_status_type, next_mission_status_type: in_progress_status_type)
    FactoryBot.create(:mission_status_action, company: company, previous_mission_status_type: todo_status_type, next_mission_status_type: in_progress_status_type)
    # in progress => to do
    # in progress => completed
    # in progress => uncompleted
    FactoryBot.create(:mission_status_action, company: company, previous_mission_status_type: todo_status_type, next_mission_status_type: completed_status_type)
    FactoryBot.create(:mission_status_action, company: company, previous_mission_status_type: completed_status_type, next_mission_status_type: completed_status_type)
    FactoryBot.create(:mission_status_action, company: company, previous_mission_status_type: uncompleted_status_type, next_mission_status_type: completed_status_type)
    # completed => in progress
    # uncompleted => to do
    FactoryBot.create(:mission_status_action, company: company, previous_mission_status_type: in_progress_status_type, next_mission_status_type: uncompleted_status_type)
    FactoryBot.create(:mission_status_action, company: company, previous_mission_status_type: todo_status_type, next_mission_status_type: uncompleted_status_type)

    if Rails.env.development?
      # Add current location for all drivers (in Bordeaux city)
      driver_1.current_location.update_attribute(:location_detail, {
        lat: 44.854895,
        lon: -0.568097,
        date: Time.now.strftime('%FT%T.%L%:z')
      })
      driver_2.current_location.update_attribute(:location_detail, {
        lat: 44.837943,
        lon: -0.568221,
        date: Time.now.strftime('%FT%T.%L%:z')
      })
      driver_3.current_location.update_attribute(:location_detail, {
        lat: 44.861618,
        lon: -0.562277,
        date: Time.now.strftime('%FT%T.%L%:z')
      })
    end
  end

end

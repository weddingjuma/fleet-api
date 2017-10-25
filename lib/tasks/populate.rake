namespace :mapotempo_fleet do

  # Example:
  # rails locatipic:populate
  desc 'Reset the database, migrate the database, initialize with the seed data and reindex models for search'
  task :populate, [] => :environment do |_task, _args|
    unless Rails.env.production?
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
      MissionStatusType.ensure_design_document!
      MissionStatusAction.ensure_design_document!
      CurrentLocation.ensure_design_document!
      Track.ensure_design_document!

      # Company
      company = FactoryGirl.create(:company, name: 'default')

      # Users for connexion
      FactoryGirl.create(:user, company: company, sync_user: 'default', password: '123456', email: 'fleet@mapotempo.com', vehicle: false)

      # Driver users
      driver_roles = %w[mission.creating mission.updating mission.deleting current_location.creating current_location.updating track.creating track.updating]
      driver_1 = FactoryGirl.create(:user, company: company, sync_user: 'driver1', password: '123456', email: 'driver1@mapotempo.com', vehicle: true, roles: driver_roles)
      driver_2 = FactoryGirl.create(:user, company: company, sync_user: 'driver2', password: '123456', email: 'driver2@mapotempo.com', vehicle: true, roles: driver_roles)
      driver_3 = FactoryGirl.create(:user, company: company, sync_user: 'driver3', password: '123456', email: 'driver3@mapotempo.com', vehicle: true, roles: driver_roles)

      # Mission status types
      todo_status_type = FactoryGirl.create(:mission_status_type, company: company, label: 'To do', color: '#ff0000')
      pending_status_type = FactoryGirl.create(:mission_status_type, company: company, label: 'Pending', color: '#66ff33')
      completed_status_type = FactoryGirl.create(:mission_status_type, company: company, label: 'Completed', color: '#0000ff')
      uncompleted_status_type = FactoryGirl.create(:mission_status_type, company: company, label: 'Uncompleted', color: '#cc0099')

      # Associate a default status type to company for new missions
      company.update_attribute(:default_mission_status_type_id, todo_status_type.id)

      # Mission status actions
      # to do => pending
      # pending => completed
      # pending => uncompleted
      FactoryGirl.create(:mission_status_action, company: company, label: 'To pending', previous_mission_status_type: todo_status_type, next_mission_status_type: pending_status_type)
      FactoryGirl.create(:mission_status_action, company: company, label: 'To completed', previous_mission_status_type: pending_status_type, next_mission_status_type: completed_status_type)
      FactoryGirl.create(:mission_status_action, company: company, label: 'To uncompleted', previous_mission_status_type: pending_status_type, next_mission_status_type: uncompleted_status_type)

      # Add current location for all drivers (in Bordeaux)
      driver_1.current_location.update_attribute(:locationDetail, {
        lat: 44.854895,
        lon: -0.568097,
        date: Time.now.strftime('%FT%T.%L%:z')
      })
      driver_2.current_location.update_attribute(:locationDetail, {
        lat: 44.837943,
        lon: -0.568221,
        date: Time.now.strftime('%FT%T.%L%:z')
      })
      driver_3.current_location.update_attribute(:locationDetail, {
        lat: 44.861618,
        lon: -0.562277,
        date: Time.now.strftime('%FT%T.%L%:z')
      })
    end
  end

end

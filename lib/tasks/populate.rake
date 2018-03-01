# Copyright © Mapotempo, 2017
#
# This file is part of Mapotempo.
#
# Mapotempo is free software. You can redistribute it and/or
# modify since you respect the terms of the GNU Affero General
# Public License as published by the Free Software Foundation,
# either version 3 of the License, or (at your option) any later version.
#
# Mapotempo is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the Licenses for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with Mapotempo. If not, see:
# <http://www.gnu.org/licenses/agpl.html>
#
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
    SchemaMigration.ensure_design_document!
    MetaInfo.ensure_design_document!

    # MetaInfo
    mi = MetaInfo.last
    if mi
      mi.update(server_version: SERVER_VERSION, minimal_client_version: MINIMAL_CLIENT_VERSION)
    else
      MetaInfo.create(server_version: SERVER_VERSION, minimal_client_version: MINIMAL_CLIENT_VERSION)
    end

    # Admin
    admin = FactoryBot.create(:admin, name: 'Admin', email: 'admin@mapotempo.com', password: '123456')

    # Company
    company = FactoryBot.create(:company, name: 'default')

    # Users for connexion
    FactoryBot.create(:user, company: company, name: 'default', password: '123456', email: 'fleet@mapotempo.com', vehicle: false)

    # Driver users for testing purpose
    driver_roles = %w[mission.updating mission.deleting mission_status.creating mission_status.updating mission_status.deleting user_settings.creating user_settings.updating user_current_location.creating user_current_location.updating user_track.creating user_track.updating]
    driver_1 = FactoryBot.create(:user, company: company, name: 'driver1', password: '123456', email: 'driver1@mapotempo.com', vehicle: true, roles: driver_roles)
    driver_2 = FactoryBot.create(:user, company: company, name: 'driver2', password: '123456', email: 'driver2@mapotempo.com', vehicle: true, roles: driver_roles)
    driver_3 = FactoryBot.create(:user, company: company, name: 'driver3', password: '123456', email: 'driver3@mapotempo.com', vehicle: true, roles: driver_roles)

    # Create default workflow
    company.set_workflow

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

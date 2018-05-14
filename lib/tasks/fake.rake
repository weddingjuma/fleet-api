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
  desc 'Create a fake company'
  task :fake, [] => :environment do |_task, _args|
    `spring stop` if Rails.env.development?

    # Company
    company = FactoryBot.create(:company, name: 'default')

    # Users for connexion
    FactoryBot.create(:user, company: company, name: 'default', password: '123456', email: 'fleet@mapotempo.com', vehicle: false)

    # Driver users for testing purpose
    driver_roles = %w[mission.updating mission_action.creating mission_action.updating user_settings.creating user_settings.updating user_current_location.creating user_current_location.updating user_track.creating user_track.updating]
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

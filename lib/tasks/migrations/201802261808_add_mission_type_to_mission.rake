# Copyright © Mapotempo, 2018
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

  desc 'Add mission_type field to missions'
  task :migration_201802261139_add_mission_type_to_missions, [] => :environment do |_task, _args|

    # Verify migration execution
    migration_name = 'migration_201802261139_add_mission_type_to_missions'.freeze
    if SchemaMigration.find_by(migration_name)
      p 'migration aborted, reason : already executed'
      next
    end

    if SERVER_VERSION == 1

      Mission.all.map do |mission|

        mission.update_attribute(:mission_type, 'mission')

      end

    end

    # Save migration execution
    SchemaMigration.create(migration: migration_name, date: DateTime.now.to_s)
  end
end

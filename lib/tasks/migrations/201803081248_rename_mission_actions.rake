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
  task :migration_201803081248_rename_mission_actions, [] => :environment do |_task, _args|

    # Verify migration execution
    migration_name = _task.name.split(':').last.freeze
    if SchemaMigration.find_by(migration_name)
      p 'migration aborted, reason : already executed'
      next
    end

    # Mission.all.each do |m|
    #   m.mission_statuses
    # end

    class MissionStatus < ApplicationRecord
      view :all
    end
    MissionStatus.all.each(&:destroy)

    class MissionStatusAction < ApplicationRecord
      view :all
    end
    MissionStatusAction.all.each(&:destroy)

    MissionStatusType.all.each(&:destroy)

    Mission.all.each(&:destroy)

    # Call refresh workflow
    Rake.application.invoke_task('mapotempo_fleet:reinit_workflow')

    # Update roles
    User.all.to_a.each{ |user|
      user.roles = %w[mission.updating mission_action.creating mission_action.updating user_settings.creating user_settings.updating user_current_location.creating user_current_location.updating user_track.creating user_track.updating]
      user.save
    }

    # Call SyncFunction to update user channels
    User.all.each(&:touch_now!)

    # Save migration execution
    SchemaMigration.create(migration: migration_name, date: DateTime.now.to_s)
  end
end

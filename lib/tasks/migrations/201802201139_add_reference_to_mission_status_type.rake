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

  desc 'Add reference field to missions status type'
  task :migration_201802201139_add_reference_to_mission_status_type, [] => :environment do |_task, _args|

    # Verify migration execution
    migration_name = _task.name.split(':').last.freeze
    if SchemaMigration.find_by(migration_name)
      p 'migration aborted, reason : already executed'
      next
    end

    MissionStatusType.all.map do |mission_status_type|
      reference = if mission_status_type.label == 'To do' || mission_status_type.label == 'Planifié'
                    'to_do'
                  elsif mission_status_type.label == 'In progress' || mission_status_type.label == 'En cours'
                    'in_progress'
                  elsif mission_status_type.label == 'Completed' || mission_status_type.label == 'Réalisé'
                    'completed'
                  elsif mission_status_type.label == 'Uncompleted' || mission_status_type.label == 'Rejeté'
                    'uncompleted'
                  end

      mission_status_type.update_attribute(:reference, reference) if reference
    end

    # Save migration execution
    SchemaMigration.create(migration: migration_name, date: DateTime.now.to_s)
  end
end

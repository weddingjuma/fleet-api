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
  task :migration_201805111520_index_mission, [] => :environment do |_task, _args|

    #Verify migration execution
    migration_name = _task.name.split(':').last.freeze
    if SchemaMigration.find_by(migration_name)
      p 'migration aborted, reason : already executed'
      next
    end

    # Check and create index type if necessary (iso : populate)
    bucket_name = Mission.bucket.bucket
    index_type = Mission.bucket.n1ql.select('*').from("system:indexes").where("name=\"#{bucket_name}_mission\"").results.first
    if(!index_type)
      # Query type : CREATE INDEX `fleet-dev_mission` ON `fleet-dev`(`company_id`, `sync_user`) WHERE type='mission'
      Mission.bucket.n1ql.create_index("`#{bucket_name}_mission` ON `#{bucket_name}`(`company_id`, `sync_user`) WHERE type='mission'").results.to_a
    end

    #Save migration execution
    SchemaMigration.create(migration: migration_name, date: DateTime.now.to_s)
  end
end

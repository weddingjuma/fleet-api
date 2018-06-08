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

  desc 'Index type field'
  task :migration_201806081659_index_type, [] => :environment do |_task, _args|

    #Verify migration execution
    migration_name = _task.name.split(':').last.freeze
    if SchemaMigration.find_by(migration_name)
      p 'migration aborted, reason : already executed'
      next
    end

    # Check and create index type if necessary (iso : populate)
    bucket_name = Mission.bucket.bucket
    index_name = bucket_name + "-type"
    index_type = Mission.bucket.n1ql.select('*').from("system:indexes").where("name=\"#{index_name}\"").results.first
    if(!index_type)
      # CREATE INDEX `fleet-dev-type` ON `fleet-dev`(`type`)
      Mission.bucket.n1ql.create_index("`#{index_name}` ON `#{bucket_name}`(`type`)").results.to_a
    end

    #Save migration execution
    SchemaMigration.create(migration: migration_name, date: DateTime.now.to_s)
  end
end

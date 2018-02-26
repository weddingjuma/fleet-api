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

  desc 'apply all unexecuted migrations'
  task :migrate, [] => :environment do |_task, _args|

    # ===============================================================
    # == 1) - apply ensure_couchbase_views to ensure documents schema
    # ===============================================================

    puts ' - apply task: ensure_couchbase_views'
    Rake.application.invoke_task('mapotempo_fleet:ensure_couchbase_views')

    # ====================================
    # == 2) - execute unapplied migrations
    # ====================================

    puts ' - execute migrations'
    # Select filter migration rake task
    migrations = Rake.application.tasks.select do |task|
        task.name.match('mapotempo_fleet:migration_\d+')
    end

    migration_counter = 0
    migrations.each do |task|

        migration_name = task.name.split(':')[1]
        if SchemaMigration.find_by(migration_name)
            next
        else
            puts '   migrate: ' + migration_name
            Rake.application.invoke_task(task.name)
            migration_counter+=1
        end

    end

    puts '   ' + migration_counter.to_s + ' migration'.pluralize(migration_counter) + ' executed'


    # =========================================================================
    # == 3) - apply create_update_meta_info to ensure meta_info doc consistancy
    # =========================================================================

    puts ' - apply task: create_update_meta_info task'
    Rake.application.invoke_task('mapotempo_fleet:create_update_meta_info')
  end

end

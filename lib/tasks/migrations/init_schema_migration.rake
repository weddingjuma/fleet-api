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

  desc 'Init schema migration'
  task :init_schema_migration, [] => :environment do |_task, _args|

    migrations = Rake.application.tasks.select do |task|
      task.name.match('mapotempo_fleet:migration_\d+')
    end.sort_by(&:name)

    migrations.each do |task|
      SchemaMigration.create!(migration: task.name.split(':')[1], date: Time.now.to_s)
    end

  end
end

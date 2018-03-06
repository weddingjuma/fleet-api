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

  desc 'Add default_language field to companies'
  task :migration_201803021605_add_default_language_to_company, [] => :environment do |_task, _args|

    # Verify migration execution
    migration_name = _task.name.split(':').last.freeze
    if SchemaMigration.find_by(migration_name)
      p 'migration aborted, reason : already executed'
      next
    end

    if SERVER_VERSION == 1

      Company.all.map do |company|

        company.update_attribute(:default_language, 'fr')

      end

    end

    # Save migration execution
    SchemaMigration.create(migration: migration_name, date: DateTime.now.to_s)
  end
end

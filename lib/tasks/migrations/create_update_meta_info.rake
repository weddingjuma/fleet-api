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

  desc 'Create update meta info'
  task :create_update_meta_info, [] => :environment do |_task, _args|

    server_version = SERVER_VERSION
    minimal_client_version = MINIMAL_CLIENT_VERSION
    mi = MetaInfo.last

    if mi
      mi.update(server_version: server_version, minimal_client_version: minimal_client_version)
    else
      MetaInfo.create(server_version: server_version, minimal_client_version: minimal_client_version)
    end

  end
end

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

  desc 'Ensure couchbase views creation/update'
  task :ensure_couchbase_views, [] => :environment do |_task, _args|

    Admin.ensure_design_document!
    Company.ensure_design_document!
    User.ensure_design_document!
    Mission.ensure_design_document!
    MissionAction.ensure_design_document!
    MissionStatusType.ensure_design_document!
    MissionActionType.ensure_design_document!
    MissionsPlaceholder.ensure_design_document!
    UserCurrentLocation.ensure_design_document!
    UserSettings.ensure_design_document!
    UserTrack.ensure_design_document!
    SchemaMigration.ensure_design_document!
    MetaInfo.ensure_design_document!

  end
end

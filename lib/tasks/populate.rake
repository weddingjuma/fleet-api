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

  # Example:
  # rails mapotempo_fleet:populate
  desc 'Reset the database, migrate the database, initialize with the seed data and reindex models for search'
  task :populate, [] => :environment do |_task, _args|
    `spring stop` if Rails.env.development?

    ### Prerequisite
    # A bucket for development exists (fleet-dev for instance)
    # A sync user (sync-user for instance) is already defined with admin permissions to the previous bucket (in sync-gateway-config.json file)
    # A sync function for Sync Gateway is declared

    # Create Couchbase views for indexing
    Admin.ensure_design_document!
    Company.ensure_design_document!
    User.ensure_design_document!
    Mission.ensure_design_document!
    MissionAction.ensure_design_document!
    MissionStatusType.ensure_design_document!
    MissionActionType.ensure_design_document!
    MissionEventType.ensure_design_document!
    MissionEventTypeSendSmsApproach.ensure_design_document!
    MissionEventTypeSendSmsDeparture.ensure_design_document!
    MissionsPlaceholder.ensure_design_document!
    UserCurrentLocation.ensure_design_document!
    UserSettings.ensure_design_document!
    UserTrack.ensure_design_document!
    SchemaMigration.ensure_design_document!
    MetaInfo.ensure_design_document!

    # Check and create index type if necessary
    bucket_name = Mission.bucket.bucket
    index_type = Mission.bucket.n1ql.select('*').from("system:indexes").where("name=\"#{bucket_name}_mission\"").results.first
    if(!index_type)
      Mission.bucket.n1ql.create_index("`#{bucket_name}_mission` ON `#{bucket_name}`(`company_id`, `sync_user`) WHERE type='mission'").results.to_a
    end

    if SchemaMigration.all.to_a.empty?
      puts ' - apply task: initialize schema migration'
      Rake.application.invoke_task('mapotempo_fleet:init_schema_migration')
    end

    # MetaInfo
    mi = MetaInfo.last
    if mi
      mi.update(server_version: SERVER_VERSION, minimal_client_version: MINIMAL_CLIENT_VERSION)
    else
      MetaInfo.create(server_version: SERVER_VERSION, minimal_client_version: MINIMAL_CLIENT_VERSION)
    end

    # Admin
    admin = FactoryBot.create(:admin, name: 'Admin', email: 'admin@mapotempo.com', password: '123456')

  end

end

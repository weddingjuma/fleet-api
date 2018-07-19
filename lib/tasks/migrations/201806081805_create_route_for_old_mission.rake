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

  desc 'Create Route models for all already existing Mission'
  task :migration_201806081805_create_route_for_old_mission, [] => :environment do |_task, _args|
    # Verify migration execution
    migration_name = _task.name.split(':').last.freeze
    if SchemaMigration.find_by(migration_name)
      p 'migration aborted, reason : already executed'
      next
    end
    # Explanation
    # This migration intent to create Route model to link old missions to this new model.
    # Firstly we create a route model for each batch of missions grouped by user and day.
    # Secondly update the route_id field of each missions.

    # 1) Route insert
    # Route insert query type :
    # INSERT INTO `bucket-name` as mission (KEY k, VALUE v)
    #   SELECT
    #     "route-migrate-" || MAX(user_id) || "-" || DATE_FORMAT_STR(date, '1111-11-11') || "-" || SUBSTR(BASE64(UUID()), 0, 10) as k,
    #     {
    #       "type": "route",
    #       "user_id": max(user_id),
    #       "company_id": max(company_id),
    #       "created_at": CLOCK_LOCAL(),
    #       "updated_at": CLOCK_LOCAL(),
    #       "external_ref": "no ref",
    #       "sync_user": max(sync_user),
    #       "name": "Route " || DATE_FORMAT_STR(date, '1111-11-11'),
    #       "date": DATE_FORMAT_STR(date, '1111-11-11'),
    #       "archived": (CASE WHEN DATE_FORMAT_STR(date, '1111-11-11') < DATE_FORMAT_STR(NOW_UTC(), '1111-11-11') THEN true ELSE false END )
    #     } as v
    #   FROM `bucket-name` as mission
    #   WHERE type = "mission" AND route_id IS NOT VALUED'
    #   GROUP BY DATE_FORMAT_STR(date, '1111-11-11'), user_id
    bucket_name = Route.bucket.bucket
    Route.bucket.n1ql.insert_into(
      "`#{bucket_name}` as mission (KEY k, VALUE v)" +
      '  SELECT' +
      '    "route-migrate-" || MAX(user_id) || "-" || DATE_FORMAT_STR(date, \'1111-11-11\') as k,' +
      '    {' +
      '      "type": "route",'+
      '      "user_id": max(user_id),'+
      '      "company_id": max(company_id),'+
      '      "created_at": CLOCK_LOCAL(),'+
      '      "updated_at": CLOCK_LOCAL(),'+
      '      "external_ref": "no ref",'+
      '      "sync_user": max(sync_user),'+
      '      "name": "Route " || DATE_FORMAT_STR(date, \'1111-11-11\'),'+
      '      "date": DATE_FORMAT_STR(date, \'1111-11-11\') || "T00:00:000.000Z",'+
      '      "archived": (CASE WHEN DATE_FORMAT_STR(date, \'1111-11-11\') < DATE_FORMAT_STR(NOW_UTC(), \'1111-11-11\') THEN true ELSE false END )'+
      '    } as v'+
      "  FROM `#{bucket_name}` as mission"+
      '  WHERE type = "mission" AND route_id IS NOT VALUED' +
      '  GROUP BY DATE_FORMAT_STR(date, \'1111-11-11\'), user_id')
      .results.to_a

    # 2) Mission route_id update
    # Mission to Route link
    # UPDATE `bucket-name` as mission
    # SET route_id = "route-migrate-" || user_id || "-" || DATE_FORMAT_STR(date, '1111-11-11'), archived = (CASE WHEN DATE_FORMAT_STR(date, '1111-11-11') < DATE_FORMAT_STR(NOW_UTC(), '1111-11-11') THEN true ELSE false END )
    # WHERE type = "mission"
    Mission.bucket.n1ql.update(
      "`#{bucket_name}` as mission" +
      ' SET '+
      ' route_id = "route-migrate-" || user_id || "-" || DATE_FORMAT_STR(date, \'1111-11-11\'), ' +
      ' archived = (CASE WHEN DATE_FORMAT_STR(date, \'1111-11-11\') < DATE_FORMAT_STR(NOW_UTC(), \'1111-11-11\') THEN true ELSE false END ) ' +
      ' WHERE type = "mission"')
      .results.to_a

    # To revert this migration you can exec this query
    # 1) - DELETE FROM `bucket-name` WHERE type="route";
    # 2) - UPDATE `bucket-name` as mission SET route_id = null, archived = null WHERE type = "mission";

    #Save migration execution
    SchemaMigration.create(migration: migration_name, date: DateTime.now.to_s)
  end
end

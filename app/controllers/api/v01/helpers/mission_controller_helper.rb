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

module MissionControllerHelper

  def process_missions_params(user, route, missions_params)
    bucket_name = Mission.bucket.bucket
    valid_missions = []

    # ================================
    # 1) - Retrive existing mission id
    # ================================
    # SELECT META(mission).id as id, external_ref from `fleet-dev` as mission where type = "mission" and external_ref in ["mission-v245-2018_05_07", "mission-v250-2018_05_07"]
    external_refs = missions_params.collect do |mission_params|
      %Q(#{mission_params['external_ref']}) # Escape " char to prevent sql injection
    end
    existing_missions = Mission.bucket.n1ql
          .select('META(mission).id as id, company_id, user_id, sync_user, mission_status_type_id, quantities, route_id, external_ref, name, date, location, address, comment, phone, reference, duration, time_windows, eta, mission_type')
          .from("`#{bucket_name}` as mission")
          .where("type = \"mission\" and company_id = \"#{user.company_id}\" and external_ref in #{external_refs.to_s}")
          .results
          .collect{ |e| [e[:external_ref], e] }
          .to_h

    # ==========================================================
    # 2) - Create the bulk mission instances (without save them)
    # ==========================================================
    missions_params.collect do |params|
      mission = Mission.new
      if(existing_missions[params['external_ref']]) # From an existing mission
        merge_params = existing_missions[params['external_ref']].merge(mission_params(params)) # Merge with new permit parameter
        mission.assign_attributes(merge_params)
        mission.user = user # User Realocation
        authorize mission, :update?
      else # From an unexisting mission
        mission.assign_attributes(mission_params(params))
        mission.id = 'mission-' + SecureRandom.hex[0,9]
        mission.user = user
        mission.company = user.company
        authorize mission, :create?
      end
      mission
    end.compact
  end

  def mission_params(params)
    params.permit(
      :external_ref,
      :mission_type,
      :name,
      :date,
      :comment,
      :phone,
      :reference,
      :duration,
      :planned_travel_time,
      :planned_distance,
      quantities: [
        :deliverable_unit_id,
        :quantity,
        :label,
        :unit_icon,
        :quantity_formatted
      ],
      location: [
        :lat,
        :lon
      ],
      address: [
        :city,
        :country,
        :detail,
        :postalcode,
        :state,
        :street
      ],
      time_windows: [
        :start,
        :end
      ]
    )
  end
end

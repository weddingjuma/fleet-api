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

# == Schema Information
#
# {
#   "type": "mission_event_type_send_sms_approach",
#   "_id": "mission_event_type_send_sms_approach-XXXX"
#   "company_id": "company-XXXXX_XXXXX_XXXX_XXXXX",
#   "mission_action_type_id": "mission_action_type-XXXX",
#   "template": "",
#   "group": "default"
# }
#

class MissionEventTypeSendSmsApproach < ApplicationRecord
  include MissionEventTypeConcern
  include MissionEventTypeSendSmsConcern

  def exec(mission)
    if mission.mission_type == 'mission' && mission.planned_travel_time
      next_status_ref = mission_action_type.next_mission_status_type.reference
      if mission.mission_actions.take(mission.mission_actions.to_a.size - 1).none?{ |ma| ma.mission_action_type.next_mission_status_type.reference == next_status_ref }
        # TODO: FIXME mission.date could be a Time in couchbase orm
        mission_date = Time.parse(mission.date)
        # TODO: FIXME time_zone should set on mission
        Time.use_zone('Paris') do
          last_locations = []
          # 1st case: Compute ETA from last known location
          last_locations << mission.user.current_location.location_detail if mission.user.current_location.location_detail['date'] && mission.user.current_location.location_detail['lat'] && mission.user.current_location.location_detail['lon']
          # 2nd case: Compute ETA from last action location
          last_action = mission.mission_actions.to_a.last
          last_locations << {
            'date' => last_action['date'],
            'lat' => last_action.action_location['lat'],
            'lon' => last_action.action_location['lon']
          } if last_action['date'] && last_action.action_location['lat'] && last_action.action_location['lon']

          if !last_locations.empty? && mission.location['lat'] && mission.location['lon']
            loc = last_locations.max_by{ |l| Time.parse(l['date']) }
            lag = Time.zone.now - Time.zone.parse(loc['date'])
            mode = %w[car time]
            route = Rails.application.config.router.compute_batch(
              Rails.application.config.router_url,
              mode[0], mode[1],
              [[loc['lat'], loc['lon'], mission.location['lat'], mission.location['lon']]],
              geometry: false, traffic: true
            )

            mission.eta = Time.zone.now + route[0][1] - lag
            mission.eta_compute_mode = mode.join('_')
          else
            # 3rd case: Shift time
            mission.eta = Time.zone.parse(last_action['date']) + mission.planned_travel_time
            mission.eta_compute_mode = 'shift'
          end
          mission.eta_compute_time = Time.now.utc
          mission.save!
          mission.date = mission.eta

          send_sms(mission).any?{ |v| v } && Rails.logger.info('SMS approach sent') if mission.phone && mission.date > Time.zone.now
        end
      else
        Rails.logger.info 'Event sms approach already performed'
      end
    else
      Rails.logger.info 'Event sms approach cannot be performed for this document'
    end
  end
end

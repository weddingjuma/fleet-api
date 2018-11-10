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
#   "type": "mission_event_type_send_sms_departure",
#   "_id": "mission_event_type_send_sms_departure-XXXX"
#   "company_id": "company-XXXXX_XXXXX_XXXX_XXXXX",
#   "mission_action_type_id": "mission_status_action-XXXX",
#   "template": "",
#   "group": "default"
# }
#

class MissionEventTypeSendSmsDeparture < ApplicationRecord
  include MissionEventTypeConcern
  include MissionEventTypeSendSmsConcern

  def exec(mission)
    if mission.mission_type == 'departure'
      next_status_ref = mission_action_type.next_mission_status_type.reference
      if mission.mission_actions.take(mission.mission_actions.to_a.size - 1).none?{ |ma| ma.mission_action_type.next_mission_status_type.reference == next_status_ref }
        # TODO: FIXME mission.date could be a Time in couchbase orm
        mission_date = Time.parse(mission.date)
        # TODO: FIXME time_zone should set by mobile
        mobile_timezone = 'Paris'
        Time.use_zone(mobile_timezone) do
          time_shift = Time.zone.parse(mission.mission_actions.to_a.last.date) - mission_date

          sms_count = 0
          mission.route.missions.each do |m|
            # Shift time
            m.eta = Time.zone.parse(m.date) + time_shift
            m.eta_computed_at = Time.now.utc
            m.eta_computed_mode = 'shift'
            m.save!
            m.date = m.eta

            sms_count += send_sms(m).count{ |v| v } if m.phone && m.date > Time.zone.now
          end
          Rails.logger.info("SMS departure sent: #{sms_count}")
        end
      else
        Rails.logger.info 'Event SMS departure already performed'
      end
    else
      Rails.logger.info 'Event SMS departure cannot be performed for this document'
    end
  end
end

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
        # TODO: FIXME time_zone should set by mobile
        mobile_timezone = 'Paris'
        Time.use_zone(mobile_timezone) do
          mission.compute_or_shift_eta(mission.last_location_date, mobile_timezone)
          mission.save!
          mission.date = mission.eta

          send_sms(mission).any?{ |v| v } && Rails.logger.info('SMS approach sent') if mission.phone && mission.date > Time.zone.now
        end
      else
        Rails.logger.info 'Event SMS approach already performed'
      end
    else
      Rails.logger.info 'Event SMS approach cannot be performed for this document'
    end
  end
end

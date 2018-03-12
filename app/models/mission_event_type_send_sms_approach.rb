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

class MissionEventTypeSendSMSApproach < MissionEventTypeSendSMS

  # == Attributes ===========================================================

  # == Extensions ===========================================================

  # == Relationships ========================================================

  # == Validations ==========================================================

  # == Views ===============================================================

  # == Callbacks ============================================================

  # == Class Methods ========================================================

  # == Instance Methods =====================================================

  def exec(mission)
    if mission.mission_type == 'mission'
      if mission_action_type.previous_mission_status_type.reference == 'mission_to_do' && mission_action_type.next_mission_status_type.reference == 'mission_in_progress' && !mission.mission_actions.find{ |ma| ma.mission_status_type.reference == 'mission_in_progress' }
        Time.use_zone(mission.date.zone) do
          # Shift time
          mission.date = Time.zone.now + mission.planned_travel_time

          send_sms(mission)
        end
      end
    end
  end

end

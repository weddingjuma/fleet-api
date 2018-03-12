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

class MissionEventTypeSendSMSDeparture < MissionEventTypeSendSMS

  # == Attributes ===========================================================

  # == Extensions ===========================================================

  # == Relationships ========================================================

  # == Validations ==========================================================

  # == Views ===============================================================

  # == Callbacks ============================================================

  # == Class Methods ========================================================

  # == Instance Methods =====================================================

  def exec(mission)
    if mission.mission_type == 'departure'
      if mission_action_type.previous_mission_status_type.reference == 'departure_to_do' && mission_action_type.next_mission_status_type.reference == 'departure_loading' && !mission.mission_actions.find{ |ma| ma.next_mission_status_type.reference == 'departure_loading' }
        Time.use_zone(mission.date.zone) do
          missions_by_date = Missions.filter_by_date(mission.user_id, mission.date + 12.hours, Time.zone.now)
          time_shift = Time.zone.now - mission.date

          missions_by_date.each do |m|
            # Shift time
            m.date += time_shift

            send_sms(m)
          end
        end
      end
    end
  end

end

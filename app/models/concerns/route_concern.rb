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

module RouteConcern
  def compute_or_shift_eta(from_mission, from_location_date, timezone)
    c = nil
    self.missions.sort_by{ |m| m.date ? Time.parse(m.date) : 0 }.each{ |mission|
      c ||= true if from_mission.nil? || mission.id == from_mission.id
      if c
        mission.compute_or_shift_eta(from_location_date, timezone)
        from_location_date['date'] = "#{Time.parse(mission.eta.to_s) + mission.duration.to_i}"
        from_location_date['lat'] = mission.location['lat']
        from_location_date['lon'] = mission.location['lon']
      end
    }
  end
end

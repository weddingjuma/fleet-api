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

module MissionConcern
  def compute_or_shift_eta(from_location_date, timezone)
    if self.eta_computed_at.nil? || self.eta_computed_at < Time.now.utc - 1.minute
      ret = nil
      if self.location['lat'] && self.location['lon'] && from_location_date['lat'] && from_location_date['lon']
        router_params = self.user.router_params || {}
        router_params[:mode] ||= 'car'
        router_params[:dimension] ||= 'time'

        self.compute_eta([from_location_date['lat'], from_location_date['lon']],
          Time.zone.parse(from_location_date['date']),
          router_params,
          timezone)
        ret = true
      elsif from_location_date['date'] && self.planned_travel_time
        self.eta = Time.zone.parse(from_location_date['date']) + self.planned_travel_time
        self.eta_computed_mode = 'shift'
        ret = true
      else
        ret = false
      end
      self.eta_computed_at = Time.now.utc
      ret
    end
  end

  def last_location_date
    locations = []
    # 1st try: from last known location
    locations << self.user.current_location.location_detail.slice('date', 'lat', 'lon') if self.user.current_location.location_detail['date'] && self.user.current_location.location_detail['lat'] && self.user.current_location.location_detail['lon']
    # 2nd try: from last action location
    last_action = self.mission_actions.to_a.last
    locations << {
      'date' => last_action['date'],
      'lat' => (last_action.action_location['lat'] if last_action.action_location['lat']),
      'lon' => (last_action.action_location['lon'] if last_action.action_location['lon'])
    } if last_action && last_action['date']

    # Return location with greatest date
    locations.max_by{ |l| Time.parse(l['date']) } unless locations.empty?
  end
end

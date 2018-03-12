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
module Webhook
  class MissionStatusTypeChangesController < WebhookController
    skip_before_action :authenticate
    # after_action :verify_authorized

    def update
      mission = Mission.find_by(params[:_id], @current_user&.company_id)
      mission.mission_actions.to_a.last.mission_action_type.mission_event_types.each do |mission_event_type|
        mission_event_type.exec(mission)
      end unless mission.mission_actions.to_a.empty?
    end

  end
end

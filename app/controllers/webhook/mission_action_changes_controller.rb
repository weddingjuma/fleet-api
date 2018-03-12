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
  class MissionActionChangesController < WebhookController
    skip_before_action :authenticate
    # after_action :verify_authorized

    def events
      mission_action = MissionAction.find(params[:_id])

      # Get mission events defined for this action
      MissionEventType.all_types_by_action(key: [mission_action.mission_action_type_id, mission_action.company_id]).each{ |mission_event_type|
        specialized_type = mission_event_type.id.split('-')[0].camelcase
        mission_event_type = specialized_type.constantize.find(mission_event_type.id)
        mission_event_type.exec(mission_action.mission)
      }
    end
  end
end

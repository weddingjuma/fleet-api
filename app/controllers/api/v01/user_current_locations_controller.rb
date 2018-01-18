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
module Api::V01
  class UserCurrentLocationsController < ApiController
    after_action :verify_authorized, except: [:index]

    # get_vehicles_pos
    def index
      current_locations = UserCurrentLocation.by_company(key: @current_user.company.id).to_a

      render json: current_locations,
             each_serializer: UserCurrentLocationSerializer
    end

    def show
      user = User.find_by(params[:user_id])
      current_location = user&.current_location
      authorize current_location

      if current_location
        render json: current_location,
               serializer: UserCurrentLocationSerializer
      else
        render body: nil, status: :not_found
      end
    end

  end
end

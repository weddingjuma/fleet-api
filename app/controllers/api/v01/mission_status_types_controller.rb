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
  class MissionStatusTypesController < ApiController
    after_action :verify_authorized

    def index
      mission_status_types = if params[:sync_user]
                               user = User.find_by(params[:sync_user])
                               authorize user, :show?
                               user.company.mission_status_types.to_a
                             end

      if mission_status_types
        render json: mission_status_types,
               each_serializer: MissionStatusTypeSerializer
      else
        render body: nil, status: :not_found
      end
    end

    def create
      user = User.find_by(params[:sync_user])
      mission_status_type = MissionStatusType.new
      mission_status_type.assign_attributes(mission_status_type_params)
      mission_status_type.company = user.company
      authorize mission_status_type

      if mission_status_type.save
        render json: mission_status_type,
               serializer: MissionStatusTypeSerializer
      else
        render json: mission_status_type.errors, status: :unprocessable_entity
      end
    end

    def update
      mission_status_type = MissionStatusType.find(params[:id])
      mission_status_type.assign_attributes(mission_status_type_params)
      authorize mission_status_type

      if mission_status_type.save
        render json: mission_status_type,
               serializer: MissionStatusTypeSerializer
      else
        render json: mission_status_type.errors, status: :unprocessable_entity
      end
    end

    def destroy
      mission_status_type = MissionStatusType.find(params[:id])
      authorize mission_status_type

      if mission_status_type.destroy
        render json: mission_status_type,
               serializer: MissionStatusTypeSerializer
      else
        render json: mission_status_type.errors, status: :unprocessable_entity
      end
    end

    private

    def mission_status_type_params
      params.permit(
        :color,
        :label
      )
    end

  end
end

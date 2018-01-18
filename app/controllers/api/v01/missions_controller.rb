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
  class MissionsController < ApiController
    after_action :verify_authorized, except: [:index]

    # get_missions
    def index
      missions = if params[:user_id]
                   user = User.find_by(params[:user_id])
                   authorize user, :show?
                   user.missions.to_a
                 else
                   Mission.by_company(key: @current_user.company.id).to_a
                 end

      if missions
        render json: missions,
               root: 'missions',
               each_serializer: MissionSerializer
      else
        render body: nil, status: :not_found
      end
    end

    # set_mission
    def create
      user = User.find_by(params[:user_id])
      mission = Mission.new
      mission.assign_attributes(mission_params)
      mission.user = user
      mission.company = user.company
      authorize mission

      if mission.save
        render json: mission,
               serializer: MissionSerializer
      else
        render json: mission.errors, status: :unprocessable_entity
      end
    end

    def create_multiples
      user = User.find_by(params[:user_id])

      missions = missions_params.map do |mission_params|
        existing_mission = Mission.by_external_ref(key: [user.company_id, mission_params['external_ref']]).to_a

        # If several missions exists for the same uniq reference, delete all
        if existing_mission.size > 1
          existing_mission.map(&:destroy)
          existing_mission = nil
        else
          existing_mission = existing_mission.first
        end

        # Override mission if already exists
        mission = existing_mission || Mission.new
        mission.assign_attributes(mission_params)
        mission.user = user
        mission.company = user.company
        authorize mission, :create?
        mission.save ? mission : nil
      end.compact

      if missions.present?
        render json: missions,
               each_serializer: MissionSerializer
      else
        render json: [], status: :unprocessable_entity,
               root: 'missions'
      end
    end

    def update
      mission = Mission.find_by(params[:id], @current_user&.company_id)
      mission.assign_attributes(mission_params)
      authorize mission

      if mission.save
        render json: mission,
               serializer: MissionSerializer
      else
        render json: mission.errors, status: :unprocessable_entity
      end
    end

    # delete_mission
    def destroy
      mission = Mission.find_by(params[:id], @current_user&.company_id)
      authorize mission

      if mission.destroy
        render json: mission,
               serializer: MissionSerializer,
               destroy: true
      else
        render json: mission.errors, status: :unprocessable_entity
      end
    end

    def destroy_multiples
      if params['end_date']
        user = User.find_by(params['user_id'])
        ids = Mission.filter_by_date(user.id, params['end_date'], params['start_date'])
      elsif params['ids']
        ids = params['ids'].is_a?(String) ? params['ids'].split(',') : params['ids']
      else
        ids = []
      end

      skip_authorization if ids.empty?

      ids.map do |id|
        mission = Mission.find(id) rescue nil
        if mission
          authorize mission, :destroy?
          mission.destroy
        end
      end

      head :no_content
    end

    private

    def mission_params
      params.permit(
        :external_ref,
        :name,
        :date,
        :comment,
        :phone,
        :reference,
        :duration,
        location: [
          :lat,
          :lon
        ],
        address: [
          :city,
          :country,
          :detail,
          :postalcode,
          :state,
          :street
        ],
        time_windows: [
          :start,
          :end
        ]
      )
    end

    def missions_params
      params.permit(_json: [
        mission_attributes
      ]
      )[:_json]
    end

    def mission_attributes
      [
        :external_ref,
        :name,
        :date,
        :comment,
        :phone,
        :reference,
        :duration,
        location: [
          :lat,
          :lon
        ],
        address: [
          :city,
          :country,
          :detail,
          :postalcode,
          :state,
          :street
        ],
        time_windows: [
          :start,
          :end
        ]
      ]
    end

  end
end

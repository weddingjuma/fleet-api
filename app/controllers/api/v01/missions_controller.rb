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
    include MissionControllerHelper

    after_action :verify_authorized, except: [:index]

    # get_missions
    def index
      missions = if params[:user_id]
                   user = User.find_by(params[:user_id])
                   authorize user, :show?
                   user.missions.to_a
                 else
                   Mission.filter_company_by_date(@current_user.company.id, Time.now + (3600 * 12), Time.now - (3600 * 12))
                 end

      if missions
        render json: missions,
               root: 'missions',
               each_serializer: MissionSerializer
      else
        render body: nil, status: :not_found
      end
    end

    def show
      mission = Mission.find_by(params[:id])
      authorize mission
      if mission
        render json: mission,
               root: 'mission',
               serializer: MissionSerializer
      else
        render body: nil, status: :not_found
      end
    end

    # set_mission
    def create
      if !params[:user_id]
        return render body: nil, status: :not_found
      end

      user = User.find_by(params[:user_id])
      mission = Mission.new
      mission.assign_attributes(mission_params)
      mission.user = user
      mission.company = user.company
      authorize mission
      mission.validate
      if mission.save
        render json: mission,
               serializer: MissionSerializer
      else
        render json: mission.errors, status: :unprocessable_entity
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
      bucket_name = Mission.bucket.bucket
      user = User.find_by(params['user_id'])
      if params['end_date']
        Mission.bucket.n1ql.delete_from("`#{bucket_name}` as mission").where('type = "mission" and company_id = "' + user.company_id + '" and sync_user="' + user.sync_user + '" and date>"' + params['start_date'] + '" and date<"' + params['end_date'] + '"').results.to_a
      elsif params['ids']
        ids = params['ids'].is_a?(String) ? params['ids'].split(',') : params['ids']
        Mission.bucket.n1ql.delete_from("`#{bucket_name}` as mission").where('type = "mission" and company_id = "' + user.company_id + '" and sync_user="' + user.sync_user + '" and META(mission).id in ' + ids.to_s).results.to_a
      end
      # FIXME we should review how manage authorization for bulk delete
      skip_authorization
      head :no_content
    end

    def attachment
      Rails.logger.debug("Try to retrieve #{params[:type]} attachment for  mission : #{params[:id]}")
      mission = Mission.find(params[:id])
      authorize mission, :show?

      blob_attachment_key = "blob_/#{params[:type]}"
      return render body: '"error": "Resource not found', status: :not_found unless (mission.attributes.key?(:_attachments) and  mission.attributes[:_attachments].key?(blob_attachment_key))

      digest = mission.attributes[:_attachments]["blob_/#{params[:type]}"][:digest]
      body = Mission.bucket.get("_sync:att:#{digest}")
      Rails.logger.debug("Attachment #{params[:type]} exist for mission : #{params[:id]} with digest : #{digest}")
      content_type = mission.attributes[:_attachments]["blob_/#{params[:type]}"][:content_type]
      render body: body, content_type: content_type

      # Same using sync_gateway rest api
      # response = HTTP.get("#{Rails.configuration.x.sync_gateway_url}"+params[:id]+"/blob_%2F#{params[:type]}")
      # Rails.logger.debug("Response : #{response.code}")
      # render body: response.body, status: response.code, content_type: response.content_type.mime_type
    end

    private

    def mission_params
      params.permit(
        :route_id,
        :external_ref,
        :mission_type,
        :name,
        :date,
        :comment,
        :phone,
        :reference,
        :duration,
        :planned_travel_time,
        :planned_distance,
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
      params.permit(_json: [mission_attributes])[:_json]
    end

    def mission_attributes
      [
        :external_ref,
        :mission_type,
        :name,
        :date,
        :comment,
        :phone,
        :reference,
        :duration,
        :planned_travel_time,
        :planned_distance,
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

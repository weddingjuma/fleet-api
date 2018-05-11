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
      bucket_name = Mission.bucket.bucket
      valid_missions = []
      dates = Set.new

      # 1) - Retrive existing mission
      # SELECT META(mission).id as id, external_ref from `fleet-dev` as mission where type = "mission" and external_ref in ["mission-v245-2018_05_07", "mission-v250-2018_05_07"]
      external_refs = missions_params.collect do |mission_params|
        mission_params['external_ref']
      end
      where_statement = "type = \"mission\" and company_id = \"#{user.company_id}\" and sync_user=\"#{user.sync_user}\" and external_ref in #{%Q(external_refs.to_s)}"
      r = Mission.bucket.n1ql.select('META(mission).id as id, external_ref').from("`#{bucket_name}` as mission").where(where_statement).results.to_a
      existing_missions = Hash[r.collect{ |e| [e[:external_ref], e] }]

      # 2) - Prepare upsert query (update or insert)
      string_query =  "`#{bucket_name}` as mission (KEY, VALUE) VALUES "
      string_query += missions_params.map do |mission_params|
          mission = Mission.new
          mission.assign_attributes(mission_params)
          mission.user = user
          mission.company = user.company
          authorize mission, :create?
          id = existing_missions[mission_params['external_ref']] ? existing_missions[mission_params['external_ref']][:id] : 'mission-' + SecureRandom.hex[0,9]
          if mission.validate
            dates.add(mission.date.to_date)
            valid_missions.append(mission)
            a = mission.attributes.except('id')
            a[:type] = 'mission'
            '("' + id.to_s + '",' + a.to_json + ')'
          end
      end.compact.join(',')

      # 3) Exec upsert query and update/create placeholder
      if valid_missions.present?
        Mission.bucket.n1ql.upsert_into(string_query).results.to_a
        dates.each do |date|
          placeholder = MissionsPlaceholder.by_date(key: [user.company_id, user.sync_user, date.strftime('%F')]).to_a.first
          placeholder = MissionsPlaceholder.new if !placeholder
          placeholder.assign_attributes(company_id: user.company_id, sync_user: user.sync_user, date: date.strftime('%F'), revision: placeholder.revision ? placeholder.revision + 1 : 0)
          placeholder.save!
        end
        render json: valid_missions,
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

    private

    def mission_params
      params.permit(
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
      params.permit(_json: [
        mission_attributes
      ]
      )[:_json]
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

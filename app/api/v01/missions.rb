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
require './app/api/v01/entities/status'
require './app/api/v01/entities/mission'
require './app/models/mission'

module Api
  module V01
    class Missions < Grape::API
      helpers do
        # Never trust parameters from the scary internet, only allow the white list through.
        def mission_params
          p = ActionController::Parameters.new(params)
          p.permit(:company_id, :date, :name, :phone, :lat, :lon, owners:[])
        end

        def mission_params_patch
          p = ActionController::Parameters.new(params)
          p.permit(:date, :name, :phone, :lat, :lon, owners:[])
        end
      end

      resource :missions do
        desc 'Return missions', {
          nickname: 'mission',
          success: Mission,
          failure: [
            {code: 404, message: 'Not Found', model: ::Api::V01::Status}
          ],
          detail: ''
        }
        get do
          present Model::Mission.all(), with: Mission
        end

        desc 'Return mission', {
          nickname: 'mission',
          success: Mission,
          failure: [
            {code: 404, message: 'Not Found', model: ::Api::V01::Status}
          ],
          detail: ''
        }
        params do
          requires :id, documentation: { type: Integer, desc: 'The mission company.' }
        end
        get ':id' do
          present Model::Mission.find(params[:id]), with: Mission
        end

        desc 'Create a new user and return it', {
          nickname: 'mission',
          success: Mission,
          failure: [
            {code: 404, message: 'Not Found', model: ::Api::V01::Status}
          ],
          detail: ''
        }
        params do
          requires :company_id, documentation: { type: String, desc: 'The mission company.' }
          optional :date, documentation: { type: String, desc: 'The mission date.' }
          optional :name, documentation: { type: String, desc: 'The mission name.' }
          optional :phone, documentation: { type: String, desc: 'The mission phone.' }
          optional :owners, documentation: { type: Array[String], desc: 'The mission phone' }
          optional :lon, documentation: { type: Float, desc: 'The mission longitude location' }
          optional :lat, documentation: { type: Float, desc: 'The mission longitude lattitude' }
        end
        post do
          Model::Company.find(params[:company_id])
          mission = Model::Mission.create(mission_params)
          present mission, with: Mission
        end

        desc 'Create a new user and return it', {
          nickname: 'mission',
          success: Mission,
          failure: [
            {code: 404, message: 'Not Found', model: ::Api::V01::Status}
          ],
          detail: ''
        }
        params do
          requires :id, documentation: { type: String, desc: 'The mission company.' }
          optional :date, documentation: { type: String, desc: 'The mission date.'}
          optional :name, documentation: { type: String, desc: 'The mission name.'}
          optional :phone, documentation: { type: String, desc: 'The mission phone.'}
          optional :owners, documentation: { type: Array[String], desc: 'The mission phone'}
          optional :lon, documentation: { type: Float, desc: 'The mission longitude location'}
          optional :lat, documentation: { type: Float, desc: 'The mission longitude lattitude'}
        end
        patch ':id' do
          mission = Model::Mission.find(params[:id])
          mission.update! mission_params_patch
          present mission, with: Mission
        end

        desc 'Delete a mission', {
          nickname: 'mission',
          failure: [
            {code: 404, message: 'Not Found', model: ::Api::V01::Status}
          ],
          detail: ''
        }
        params do
          optional :id, documentation: { type: Integer }
        end
        delete ':id' do
          Model::Mission.find(params[:id]).delete
          status 204
        end
      end
    end
  end
end

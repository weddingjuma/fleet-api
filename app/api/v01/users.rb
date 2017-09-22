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
require './app/api/v01/entities/user'
require './app/models/user'

module Api
  module V01
    class Users < Grape::API
      helpers do
        # Never trust parameters from the scary internet, only allow the white list through.
        def user_params
          p = ActionController::Parameters.new(params)
          p.permit(:company_id, :user, roles: []).to_h
        end

        def user_params_patch
          p = ActionController::Parameters.new(params)
          p.permit(:user, roles: []).to_h
        end
      end

      resource :users do
        desc 'Return users', {
          nickname: 'user',
          success: User,
          failure: [
            {code: 404, message: 'Not Found', model: ::Api::V01::Status}
          ],
          detail: ''
        }
        get do
          present Model::User.all, with: User
        end

        desc 'Return user', {
          nickname: 'user',
          success: User,
          failure: [
            {code: 404, message: 'Not Found', model: ::Api::V01::Status}
          ],
          detail: ''
        }
        params do
          requires :id, documentation: { type: Integer }
        end
        get ':id' do
          present Model::User.find(params[:id]), with: User
        end

        desc 'Create a new user and return it', {
          nickname: 'user',
          success: User,
          failure: [
            {code: 404, message: 'Not Found', model: ::Api::V01::Status}
          ],
          detail: ''
        }
        params do
          requires :company_id, documentation: { type: String }
          requires :user, documentation: { type: String }
          requires :roles, documentation: { type: Array[String] }
        end
        post do
          Model::Company.find(params[:company_id])
          user = Model::User.create(user_params)
          present user, with: User
        end

        desc 'Update a user and return it', {
          nickname: 'user',
          success: User,
          failure: [
            {code: 404, message: 'Not Found', model: ::Api::V01::Status}
          ],
          detail: ''
        }
        params do
          requires :id, documentation: { type: Integer }
          optional :user, documentation: { type: String }
          optional :roles, documentation: { type: Array[String]}
        end
        patch ':id' do
          user = Model::User.find(params[:id])
          user.update! user_params
          present user, with: User
        end

        desc 'Delete a user', {
          nickname: 'user',
          success: User,
          failure: [
            {code: 404, message: 'Not Found', model: ::Api::V01::Status}
          ],
          detail: ''
        }
        params do
          optional :id, documentation: { type: Integer }
        end
        params do
          requires :id, documentation: { type: Integer }
        end
        delete ':id' do
          Model::User.find(params[:id]).delete
          status 204
        end
      end
    end
  end
end

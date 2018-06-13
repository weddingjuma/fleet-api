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
  class UsersController < ApiController
    after_action :verify_authorized, except: [:index]

    # get_vehicles
    def index
      users = User.by_company(key: @current_user.company.id).to_a

      users = users.select(&:vehicle) if params[:with_vehicle]

      render json: users,
             root: 'users',
             each_serializer: UserSerializer
    end

    # check_auth
    def show
      user = User.find_by(params[:id])
      authorize user

      if user
        render json: user,
               serializer: UserSerializer
      else
        render body: nil, status: 404
      end
    end

    def create
      user = User.new
      user.assign_attributes(user_params)
      user.company = @current_user.company
      authorize user

      if user.save
        render json: user,
               serializer: UserSerializer
      else
        render json: user.errors, status: :unprocessable_entity
      end
    end

    def update
      user = User.find_by(params[:id])
      user.assign_attributes(user_params)
      authorize user

      if user.save
        render json: user,
               serializer: UserSerializer
      else
        render json: user.errors, status: :unprocessable_entity
      end
    end

    def destroy
      user = User.find_by(params[:id])
      authorize user

      if user.destroy
        render json: user,
               serializer: UserSerializer
      else
        render json: user.errors, status: :unprocessable_entity
      end
    end

    private

    def user_params
      params.permit(
        :sync_user,
        :name,
        :email,
        :password,
        :vehicle,
        :phone,
        roles: []
      )
    end

  end
end

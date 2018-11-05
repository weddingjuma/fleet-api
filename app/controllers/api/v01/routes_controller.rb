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

module Api::V01
  class RoutesController < ApiController
    include MissionControllerHelper

    after_action :verify_authorized, except: [:index]

    # get_route
    def index
      from_param = nil
      to_param = nil
      begin
        from_param = Time.parse(params[:from]) unless params[:from].blank?
        to_param = Time.parse(params[:to]) unless params[:to].blank?
      rescue ArgumentError => error
        return render json: error.message.to_json, status: :bad_request
      end

      routes = if params[:user_id]
                   user = User.find_by(params[:user_id])
                   authorize user, :show?
                   user.routes.to_a
                 else
                   Route.by_company(key: @current_user.company.id).to_a
                 end

      routes = Route.filter_by_date(routes, from_date: from_param, to_date: to_param)

      if routes
        render json: routes,
               root: 'routes',
               each_serializer: RouteSerializer,
               with_missions: with_missions?
      else
        render body: nil, status: :not_found
      end
    end

    def show
      route = Route.find_by(params[:id], @current_user&.company.id)
      authorize route, :show?
      if route
        render json: route,
               root: 'route',
               serializer: RouteSerializer,
               with_missions: with_missions?
      else
        render body: nil, status: :not_found
      end
    end

    # set_route
    def create
      if !params[:user_id]
        return render body: nil, status: :not_found
      end

      user = User.find_by(params[:user_id])
      route = Route.new
      route.assign_attributes(route_params)
      route.user = user
      route.company = user.company
      authorize route

      route.missions = process_missions_params route.user, route, params[:missions] if params[:missions]

      if route.save
        render json: route,
               serializer: RouteSerializer,
               with_missions: with_missions?
      else
        render json: route.errors, status: :unprocessable_entity
      end
    end

    def update
      route = Route.find_by(params[:id], @current_user&.company_id)
      route.assign_attributes(route_params)
      authorize route

      route.missions = process_missions_params route.user, route, params[:missions] if params[:missions]

      route.delete_missions = delete_missions?

      if route.save
        route.missions.reset
        render json: route,
               serializer: RouteSerializer,
               with_missions: with_missions?
      else
        render json: route.errors, status: :unprocessable_entity
      end
    end

    # delete_route
    def destroy
      route = Route.find_by(params[:id], @current_user&.company_id)
      authorize route

      if route.destroy
        render json: route,
               serializer: RouteSerializer,
               destroy: true,
               with_missions: with_missions?
      else
        render json: route.errors, status: :unprocessable_entity
      end
    end

    private

    def route_params
      params.permit(
        :name,
        :external_ref,
        :date
      )
    end

    def with_missions?
      YAML.safe_load(params[:with_missions]) == true if params[:with_missions]
    end

    def delete_missions?
      YAML.safe_load(params[:delete_missions]) == true if params[:delete_missions]
    end
  end
end

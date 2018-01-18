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
  class CompaniesController < ApiController
    before_action :authenticate_admin, only: [:index]
    skip_before_action :authenticate, only: [:index]

    after_action :verify_authorized

    def index
      authorize Company

      render json: Company.all.to_a,
             each_serializer: CompanySerializer
    end

    def show
      company = nil
      if params[:user_id]
        user = User.find_by(params[:user_id])
        authorize user
        company = user&.company
      elsif params[:id]
        company = Company.find(params[:id])
        authorize company
      end

      if company
        render json: company,
               serializer: CompanySerializer
      else
        render body: nil, status: :not_found
      end
    end

    private

    def company_params
      params.permit(
        :name
      )
    end

  end
end

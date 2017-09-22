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
require './app/api/v01/entities/company'
require './app/models/company'

module Api
  module V01
    class Companies < Grape::API
      helpers do
        # Never trust parameters from the scary internet, only allow the white list through.
        def user_params
          p = ActionController::Parameters.new(params)
          p.permit(:name, :country, :detail, :postalcode, :state, :street, :city)
        end
      end

      resource :companies do
        desc 'Return company', {
          nickname: 'company',
          success: Company,
          failure: [
            {code: 404, message: 'Not Found', model: ::Api::V01::Status}
          ],
          detail: ''
        }
        get do
          present Model::Company.all, with: Company
        end

        desc 'Return company', {
          nickname: 'company',
          success: Company,
          failure: [
            {code: 404, message: 'Not Found', model: ::Api::V01::Status}
          ],
          detail: ''
        }
        params do
          requires :id, documentation: { type: Integer }
        end
        get ':id' do
          present Model::Company.find(params[:id]), with: Company
        end

        desc 'Create a new company and return it', {
          nickname: 'company',
          success: Company,
          failure: [
            {code: 404, message: 'Not Found', model: ::Api::V01::Status}
          ],
          detail: '',
          params: Company.documentation.except(:id)
        }
        params do
          requires :name, documentation: { type: String }
          optional :country, documentation: { type: String }
          optional :detail, documentation: { type: String }
          optional :postalcode, documentation: { type: String }
          optional :state, documentation: { type: String }
          optional :street, documentation: { type: String }
          optional :city, documentation: { type: String }
          optional :email, documentation: { type: String }
        end
        post do
          company = Model::Company.create(user_params)
          present company, with: Company
        end

        desc 'Update a company and return it', {
          nickname: 'company',
          success: Company,
          failure: [
            {code: 404, message: 'Not Found', model: ::Api::V01::Status}
          ],
          detail: '',
          params: Company.documentation.except(:id)
        }
        params do
          requires :id, documentation: { type: Integer }
          optional :name, documentation: { type: String }
          optional :country, documentation: { type: String }
          optional :detail, documentation: { type: String }
          optional :postalcode, documentation: { type: String }
          optional :state, documentation: { type: String }
          optional :street, documentation: { type: String }
          optional :city, documentation: { type: String }
          optional :email, documentation: { type: String }
        end
        patch ':id' do
          p user_params
          company = Model::Company.find(params[:id])
          company.update! user_params
          present company, with: Company
        end

        desc 'Delete a company', {
          nickname: 'company',
          failure: [
            {code: 404, message: 'Not Found', model: ::Api::V01::Status}
          ],
          detail: ''
        }
        params do
          requires :id, documentation: { type: Integer }
        end
        delete ':id' do
          Model::Company.find(params[:id]).delete
          status 204
        end
      end
    end
  end
end

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

module Api
  module V01
    class Companies < Grape::API
      helpers do
        # Never trust parameters from the scary internet, only allow the white list through.
        def user_params
          p = ActionController::Parameters.new(params)
          p.permit(:name, :address_1, :address_2, :address_3, :email).to_h
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
          present DummyCompany.all, with: Company
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
          present DummyCompany.find(params[:id]), with: Company
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
          optional :address_1, documentation: { type: String }
          optional :address_2, documentation: { type: String }
          optional :address_3, documentation: { type: String }
          optional :email, documentation: { type: String }
        end
        post do
          company = DummyCompany.create(params)
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
          optional :address_1, documentation: { type: String }
          optional :address_2, documentation: { type: String }
          optional :address_3, documentation: { type: String }
          optional :email, documentation: { type: String }
        end
        patch ':id' do
          company = DummyCompany.find(params[:id]).update(params)
          present company, with: Company
        end

        desc 'Delete a company', {
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
        delete ':id' do
          DummyCompany.find(params[:id]).destroy()
        end
      end
    end
  end
end

#######################
# DUMMY COMPANY MODEL #
#######################

class DummyCompany < ActiveHash::Base
  fields :name, :address_1, :address_2, :address_3, :email

  def update hash
    hash.symbolize_keys!
    if hash[:name]
      self.name = hash[:name]
    end
    if hash[:address_1]
      self.address_1 = hash[:address_1]
    end
    if hash[:address_2]
      self.address_2 = hash[:address_2]
    end
    if hash[:address_3]
      self.address_3 = hash[:address_3]
    end
    if hash[:email]
      self.email = hash[:email]
    end
    self.save
    return self
  end

  def destroy
    p "Destroy wasn't implement in the #{self.to_s} model"
  end
end

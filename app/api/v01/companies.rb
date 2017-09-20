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
          requires :id, type: String, desc: 'Company ID.'
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
          detail: ''
        }
        params do
          requires(:company, type: Hash, documentation: {param_type: 'body'}) do
            requires(:name, type: String)
          end
        end
        post do
          company = DummyCompany.create(name: params[:company][:name])
          present company, with: Company
        end

        desc 'Update a company and return it', {
          nickname: 'company',
          success: Company,
          failure: [
            {code: 404, message: 'Not Found', model: ::Api::V01::Status}
          ],
          detail: ''
        }
        params do
          requires :id, type: String, desc: 'Company ID.'
          requires(:company, type: Hash, documentation: {param_type: 'body'}) do
            optional(:name, type: String)
            optional(:address_1, type: String)
            optional(:address_2, type: String)
            optional(:address_3, type: String)
            optional(:email, type: String)
          end
        end
        patch ':id' do
          company = DummyCompany.find(params[:id]).update(params[:company])
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
          requires :id, type: String, desc: 'Company ID.'
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
    ''
  end
end

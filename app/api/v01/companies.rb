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
          id = params[:id]
          companies = DummyCompanies.instance.all()
          if companies == nil
            status 404
            error!({status: 'Not Found', detail: "Not found company with id='#{id}'"}, 404)
          else
            present companies, with: Company
          end
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
          id = params[:id]
          company = DummyCompanies.instance.find(id)
          if company == nil
            status 404
            error!({status: 'Not Found', detail: "Not found company with id='#{id}'"}, 404)
          else
            present company, with: Company
          end
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
          name = params[:company][:name]
          company = DummyCompanies.instance.create(name)
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
            requires(:name, type: String)
          end
        end
        put ':id' do
          id = params[:id]
          company = DummyCompanies.instance.find(id)
          if company == nil
            status 404
            error!({status: 'Not Found', detail: "Not found company with id='#{id}'"}, 404)
          else
            company.name = params[:company][:name]
            present company, with: Company
          end
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
            requires(:name, type: String)
          end
        end
        patch ':id' do
          id = params[:id]
          company = DummyCompanies.instance.find(id)
          if company == nil
            status 404
            error!({status: 'Not Found', detail: "Not found company with id='#{id}'"}, 404)
          else
            company.name = params[:company][:name]
            present company, with: Company
          end
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
          id = params[:id]
          company = DummyCompanies.instance.find(id)
          if company == nil
            status 404
            error!({status: 'Not Found', detail: "Not found company with id='#{id}'"}, 404)
          else
            DummyCompanies.instance.delete(id)
            status 204
          end
        end
      end
    end
  end
end

#############################################
# DUMMY ACTIVE RECORD MODEL COMPANY MANAGER #
#############################################
class DummyCompany
  attr_accessor :name, :id
end

class DummyCompanies < Hash
  include Singleton

  attr_accessor :counter_id

  def initialize
    @counter_id = 0
  end

  def create(company_name)
    c = DummyCompany.new
    c.name = company_name
    c.id = counter_id.to_s
    self[counter_id] = c
    @counter_id = @counter_id + 1
    return c
  end

  def find(id)
    self[id.to_i]
  end

  def delete(id)
    super(id.to_i)
  end

  def all()
    self.values
  end
end

a = DummyCompanies.instance
a.create("company_1")
a.create("company_2")
a.create("company_3")

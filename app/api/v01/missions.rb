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

module Api
  module V01
    class Missions < Grape::API
      helpers do
        # Never trust parameters from the scary internet, only allow the white list through.
        def mission_params
          p = ActionController::Parameters.new(params)
          p.permit(:company_id, :delivery_date, :name, :phone, owners:[], location:[:lat, :lon]).to_h
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
          present DummyMission.all(), with: Mission
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
          present DummyMission.find(params[:id]), with: Mission
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
          optional :delivery_date, documentation: { type: String, desc: 'The mission delivery_date.' }
          optional :name, documentation: { type: String, desc: 'The mission name.' }
          optional :phone, documentation: { type: String, desc: 'The mission phone.' }
          optional :owners, documentation: { type: Array[String], desc: 'The mission phone' }
          optional :location, documentation: { type: Location, desc: 'The mission location' }
        end
        post do
          mission = DummyMission.create(mission_params)
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
          optional :delivery_date, documentation: { type: String, desc: 'The mission delivery_date.' }
          optional :name, documentation: { type: String, desc: 'The mission name.' }
          optional :phone, documentation: { type: String, desc: 'The mission phone.' }
          optional :owners, documentation: { type: Array[String], desc: 'The mission phone' }
          optional :location, documentation: { type: Location, desc: 'The mission location' }
        end
        patch ':id' do
          mission = DummyMission.find(params[:id]).update(mission_params)
          present mission, with: Mission
        end
      end
    end
  end
end


####################
# DUMMY MISSION MODEL #
####################

class DummyMission < ActiveHash::Base
  fields :company_id, :owners, :delivery_date, :name, :phone, :location

  def update hash
    hash.symbolize_keys!
    if hash[:company_id]
      self.company_id = hash[:company_id]
    end
    if hash[:delivery_date]
      self.delivery_date = hash[:delivery_date]
    end
    if hash[:name]
      self.name = hash[:name]
    end
    if hash[:phone]
      self.phone = hash[:phone]
    end
    if hash[:owners]
      self.owners = hash[:owners]
    end
    if hash[:location]
      self.location = hash[:location]
    end
    self.save
    return self
  end

  def destroy
    p "Destroy wasn't implement in the #{self.to_s} model"
  end
end

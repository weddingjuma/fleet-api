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
# CREATE INDEX `reporting_mission_action` ON `fleet-prod`(`company_id`,`type`) WHERE (`type` = "mission_action")

module Api::V01
    class AttachmentsController < ApiController
        after_action :verify_authorized

        def show
            Rails.logger.debug("Exec query for route : #{params[:id]}")
            mission = Mission.find(params[:id])
            authorize mission, :show?

            response = HTTP.get("#{Rails.configuration.x.sync_gateway_url}"+params[:id]+"/blob_%2Fsurvey_signature")
            Rails.logger.debug("Response : #{response.code}")

            render body: response.body, status: response.code, content_type: response.content_type.mime_type
        end

    end
end
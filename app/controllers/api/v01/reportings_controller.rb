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
require 'csv'
require 'json'

module Api::V01
    class ReportingsController < ApiController
        after_action :verify_authorized, except: [:index]

        def index
            json = Rails.cache.fetch(request.original_url) do
                from_param = nil
                to_param = nil
                begin
                    from_param = Time.parse(params[:from]) unless params[:from].blank?
                    to_param = Time.parse(params[:to]) unless params[:to].blank?
                rescue ArgumentError => error
                    return render json: error.message.to_json, status: :bad_request
                end
                
                if with_action?
                    mission_action_reporting(user_id: user_param, from_date: from_param, to_date: to_param)
                else
                    mission_reporting(user_id: user_param, from_date: from_param, to_date: to_param)
                end
            end

            respond_to do |format|
                format.json { render json: json }
                format.csv { send_data json_to_csv(json), filename: Date.today.to_s + "-mapotempo-reporting.csv" }
            end
        end

        def show
            route = Route.find(params[:id])
            authorize route, :show?

            json = Rails.cache.fetch(request.original_url) do
                Rails.logger.debug("Exec query for company : #{@current_user.company.id}")
                Rails.logger.debug("Exec query for route : #{params[:id]}")

                if with_action?
                    mission_action_reporting(route_id: params[:id], user_id: user_param)
                else
                    mission_reporting(route_id: params[:id], user_id: user_param)
                end
            end

            respond_to do |format|
                format.json { render json: json }
                format.csv { send_data json_to_csv(json), filename: Date.today.to_s + "-mapotempo-reporting.csv" }
            end
        end

        def survey
            Rails.logger.debug("Exec query for company : #{@current_user.company.id}")
            Rails.logger.debug("Exec query for route : #{params[:id]}")
        end

        private

        def with_action?
            YAML.safe_load(params[:with_action]) == true if params[:with_action]
        end

        def mission_reporting(route_id: nil, user_id: nil, from_date: nil, to_date: nil)
            Rails.logger.debug("from date : #{from_date}")
            Rails.logger.debug("to date : #{to_date}")

            bucket_name = Route.bucket.bucket
            Rails.logger.debug("Exec query for company : #{@current_user.company.id}")

            # FIXME TO NOT COMMIT
            n1ql_timeout_config 100_000_000

            query = Route.bucket.n1ql()
            .select(
                ' META(mission).id AS mission_id,' +
                ' mission.external_ref AS mission_external_ref,' +
                ' `user`.email AS user_email,' +
                ' `user`.name AS user_name,' +
                ' META(route).id AS route_id,' +
                ' route.date AS route_date,' +
                ' route.name AS route_name,' +
                ' mission.date AS mission_date,' +
                ' mission.name AS mission_name,' +
                ' mission.time_windows[0] AS mission_time_window_1,' +
                ' mission.time_windows[1] AS mission_time_window_2,' +
                ' mission.comment AS mission_comment,' +
                " CASE WHEN `mission`.`survey_signature` IS VALUED THEN #{qaug('survey_signature')} ELSE null END AS mission_survey_signature," +
                " CASE WHEN `mission`.`survey_picture` IS VALUED THEN #{qaug('survey_picture')} ELSE null END AS mission_survey_picture," +
                ' CASE WHEN `mission`.`survey_location` IS VALUED THEN `mission`.`survey_location` ELSE {"lon": null, "lat": null} END AS mission_survey_location,' +
                ' mission.duration AS mission_duration,' +
                ' mission_status_type.label AS mission_action_type_label')
            .from(
                " `#{bucket_name}` AS mission" +
                "  JOIN `#{bucket_name}` AS mission_status_type ON KEYS mission.mission_status_type_id" +
                "  JOIN `#{bucket_name}` AS `user` ON KEYS mission.user_id" +
                "  JOIN `#{bucket_name}` AS route ON KEYS mission.route_id")
            .where(
                ' mission.type = "mission" AND' +
                " mission.company_id = \"#{@current_user.company.id}\" AND" +
                (from_date ? " mission.date >= \"#{from_date.iso8601}\" AND" : '') +
                (to_date ? " mission.date < \"#{to_date.iso8601}\" AND" : '') +
                ' mission_status_type.type = "mission_status_type" AND' +
                (user_id ? " mission.user_id=\"#{user_id}\" AND" : '') +
                ' `user`.type="user" AND' +
                (route_id ? " META(route).id=\"#{route_id}\" AND" : '') +
                ' route.type= "route"')
            .order_by(
                "route.date," +
                "`user`.email," +
                "mission.date")

            t = Time.now
            res = query.results.to_json
            Rails.logger.debug("Query execution : #{Time.now - t}s")
            res
        end
        
        def mission_action_reporting(route_id: nil, user_id: nil, from_date: nil, to_date: nil)
            Rails.logger.debug("from date : #{from_date}")
            Rails.logger.debug("to date : #{to_date}")

            bucket_name = Route.bucket.bucket
            Rails.logger.debug("Exec query for company : #{@current_user.company.id}")

            # FIXME TO NOT COMMIT
            n1ql_timeout_config 100_000_000

            query = Route.bucket.n1ql()
            .select(
                ' META(mission).id AS mission_id,' +
                ' mission.external_ref AS mission_external_ref,' +
                ' `user`.email AS user_email,' +
                ' `user`.name AS user_name,' +
                ' META(route).id AS route_id,' +
                ' route.date AS iso_date_time,' +
                ' route.date AS date_localized,' +
                ' route.date AS time_localized,' +
                ' route.name AS route_name,' +
                ' mission.date AS mission_date,' +
                ' mission.name AS mission_name,' +
                ' mission.time_windows[0] AS mission_time_window_1,' +
                ' mission.time_windows[1] AS mission_time_window_2,' +
                ' mission.comment AS mission_comment,' +
                " CASE WHEN `mission`.`survey_signature` IS VALUED THEN #{qaug('survey_signature')} ELSE null END AS mission_survey_signature," +
                " CASE WHEN `mission`.`survey_picture` IS VALUED THEN #{qaug('survey_picture')} ELSE null END AS mission_survey_picture," +
                ' CASE WHEN `mission`.`survey_location` IS VALUED THEN `mission`.`survey_location` ELSE {"lon": null, "lat": null} END AS mission_survey_location,' +
                ' mission.duration AS mission_duration,' +
                ' mission_action.date AS mission_action_date,' +
                ' mission_action.action_location AS mission_action_location,' +
                ' mission_status_type.label AS mission_action_type_label')
            .from(
                " `#{bucket_name}` AS mission_action" +
                "  JOIN `#{bucket_name}` AS mission_action_type ON KEYS mission_action.mission_action_type_id" +
                "  JOIN `#{bucket_name}` AS mission_status_type ON KEYS mission_action_type.next_mission_status_type_id" +
                "  JOIN `#{bucket_name}` AS mission ON KEYS mission_action.mission_id" +
                "  JOIN `#{bucket_name}` AS `user` ON KEYS mission.user_id" +
                "  JOIN `#{bucket_name}` AS route ON KEYS mission.route_id")
            .where(
                'mission_action.type = "mission_action" AND' +
                " mission_action.company_id = \"#{@current_user.company.id}\" AND" +
                ' mission_action_type.type = "mission_action_type" AND' +
                ' mission_status_type.type = "mission_status_type" AND' +
                ' mission.type = "mission" AND' +
                (from_date ? " mission.date >= \"#{from_date.iso8601}\" AND" : '') +
                (to_date ? " mission.date < \"#{to_date.iso8601}\" AND" : '') +
                (user_id ? " mission.user_id=\"#{user_id}\" AND" : '') +
                ' `user`.type="user" AND' +
                (route_id ? " META(route).id=\"#{route_id}\" AND" : '') +
                ' route.type= "route"')
            .order_by(
                "route.date," +
                "`user`.email," +
                "mission.date," +
                "mission_action.date;")

            t = Time.now
            res = query.results.to_json
            Rails.logger.debug("Reporting query execution time: #{Time.now - t}s")
            res
        end

        def user_param()
            if params[:user_id]
                user = User.find_by(params[:user_id])
                authorize user, :show?
                return user.id
            end
        end

        # Query Attachment Url Generator
        def qaug(type)
            return "\"#{request.base_url}/api/0.1/missions/\" || META(mission).id || \"/attachment/#{type}?api_key=#{@current_user.api_key}\""
        end

        def json_to_csv(json_string)
            json_array = JSON.parse(json_string)
            headers = collect_keys(json_array.first) 
            CSV.generate(:write_headers=> true, :headers => headers) do |csv|
                json_array.each { |item| csv << collect_values(item) }
            end
        end

        def collect_keys(hash, prefix = nil)
            arr = hash.map do |key, value|
                if value.class != Hash
                    if prefix
                        "#{prefix}.#{key}"
                    else
                        key
                    end
                else
                    if prefix
                        collect_keys(value, "#{prefix}.#{key}")
                    else
                        collect_keys(value, "#{key}")
                    end
                end
            end
            arr.flatten.reverse
        end

        def collect_values(hash)
            arr = hash.map do |key, value|
                if value.class != Hash
                    if (value.class == Array)
                        value.join(',')
                    else
                        value
                    end
                else
                    collect_values(value)
                end
            end
            arr.flatten.reverse
        end

        def n1ql_timeout_config(timeout)
        # This configure n1ql timeout query
        # Issue was open here https://github.com/cotag/libcouchbase/issues/18
        handle = ::Company.bucket.connection.handle
        ::Libcouchbase::Ext.cntl_setu32(handle, 61, timeout)
        retry_config = (1 << 16) | 3
        ::Libcouchbase::Ext.cntl_setu32(handle, 0x24, retry_config)
        end
    end
end
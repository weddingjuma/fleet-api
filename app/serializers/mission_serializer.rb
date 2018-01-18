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
class MissionSerializer < ActiveModel::Serializer
  attributes :id,
             :company_id,
             :user_id,
             :mission_status_type_id,
             :sync_user,
             :external_ref,
             :name,
             :date,
             :location,
             :address,
             :comment,
             :phone,
             :reference,
             :duration,
             :time_windows,
             :status_type_label,
             :status_type_color

  def status_type_label
    object.mission_status_type.label if !instance_options[:destroy] && object.mission_status_type
  end

  def status_type_color
    object.mission_status_type.color if !instance_options[:destroy] && object.mission_status_type
  end
end

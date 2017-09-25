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
module Api
  module V01
    class Mission < Grape::Entity
      def self.entity_name
        'mission'
      end
      expose :id, documentation: { is_string: true, desc: 'The mission id.' }
      expose :company_id, documentation: { is_string: true, desc: 'The mission company.' }
      expose :delivery_date, documentation: { is_string: true, desc: 'The mission delivery_date.' }
      expose :name, documentation: { is_string: true, desc: 'The mission name.' }
      expose :phone, documentation: { is_string: true, desc: 'The mission phone.' }
      expose :owners, documentation: { is_array: true, desc: 'The mission owners.' }
      expose :lat, documentation: { is_float: true, desc: 'The mission location lattitude' }
      expose :lon, documentation: { is_float: true, desc: 'The mission location longitude' }
    end
  end
end

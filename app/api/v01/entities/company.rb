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
    class Company < Grape::Entity
      def self.entity_name
        'Company'
      end
      expose :id, documentation: { is_string: true, desc: 'The company id.' }
      expose :name, documentation: { is_string: true, desc: 'The company name.' }
      expose :country, documentation: { is_string: true, desc: 'The company email.' }
      expose :postalcode, documentation: { is_string: true, desc: 'The company address_2.' }
      expose :state, documentation: { is_string: true, desc: 'The company address_3.' }
      expose :street, documentation: { is_string: true, desc: 'The company email.' }
      expose :detail, documentation: { is_string: true, desc: 'The company address_1.' }
    end
  end
end

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

module MissionEventTypeConcern
  extend ActiveSupport::Concern

  included do
    attribute :group, type: String
    attribute :context # server | client (mobile)

    belongs_to :company
    belongs_to :mission_action_type

    validates_presence_of :company_id
    validate :company_id_immutable, on: :update
    validates_presence_of :mission_action_type_id

    view :all
    view :by_company, emit_key: :company_id
    view :all_types_by_action, emit_key: [:mission_action_type_id, :company_id], map: <<-EMAP
function(doc) {
    if (doc.type.startsWith("mission_event_type")) {
        emit([doc.mission_action_type_id, doc.company_id], null);
    }
}
EMAP
  end

  def company_id_immutable
    if company_id_changed?
      errors.add(:company_id, I18n.t('couchbase.errors.models.mission_event_type.company_id_immutable'))
    end
  end

end

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

# == Schema Information
#
# {
#   "type": "mission_event_type",
#   "_id": "mission_event_type-XXXX"
#   "company_id": "company-XXXXX_XXXXX_XXXX_XXXXX",
#   "mission_action_type_id": "mission_action-type-XXXX"
#   "group": "default"
# }
#

class MissionEventType < ApplicationRecord

  # == Attributes ===========================================================
  attribute :group, type: String
  attribute :context # server | client (mobile)

  # == Extensions ===========================================================

  # == Relationships ========================================================
  belongs_to :company
  belongs_to :mission_action_type

  # == Validations ==========================================================
  validates_presence_of :company_id
  validate :company_id_immutable, on: :update

  validates_presence_of :mission_action_type_id

  # == Views ===============================================================
  view :all
  view :by_company, emit_key: :company_id

  # == Callbacks ============================================================

  # == Class Methods ========================================================

  # == Instance Methods =====================================================

  private

  def company_id_immutable
    if company_id_changed?
      errors.add(:company_id, I18n.t('couchbase.errors.models.mission_event_type.company_id_immutable'))
    end
  end
end

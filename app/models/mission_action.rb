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

# == Schema Information
#
# {
#   "type": "mission_action",
#   "company_id": "company-XXXXX",
#   "mission_id": "mission-XXXXX",
#   "mission_action_type_id" : "mission_action_type-XXXX",
#   "date": "2017-08-23T18:43:56.150Z"
# }
#

class MissionAction < ApplicationRecord

  # == Attributes ===========================================================
  attribute :date
  attribute :comment
  attribute :action_location

  # == Extensions ===========================================================
  include TouchableConcern

  # == Relationships ========================================================
  belongs_to :company
  belongs_to :mission
  belongs_to :mission_action_type

  # == Validations ==========================================================
  validates_presence_of :company_id
  validate :company_id_immutable, on: :update

  validates_presence_of :mission_id
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
      errors.add(:company_id, I18n.t('couchbase.errors.models.mission_action.company_id_immutable'))
    end
  end
end

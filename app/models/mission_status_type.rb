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
#   "type": "mission_status_type",
#   "company_id": "company_XXXXX",
#   "svg_path": "M604.1,440.2h-19.1V333.2c0,...",
#   "reference": "completed",
#   "label": "Réalisé",
#   "color": "#228b22"
# }
#

class MissionStatusType < ApplicationRecord

  # == Attributes ===========================================================
  attribute :reference, type: String
  attribute :label, type: String
  attribute :color, type: String
  attribute :svg_path, type: String

  # == Extensions ===========================================================
  include TouchableConcern

  # == Relationships ========================================================
  belongs_to :company

  has_many :related_mission_types,
           foreign_key: :previous_mission_status_type_id,
           through: :mission_action_type,
           through_key: :next_mission_status_type_id,
           class_name: MissionStatusType

  # == Validations ==========================================================
  validates_presence_of :company_id
  validate :company_id_immutable, on: :update

  validates_presence_of :reference
  validates_presence_of :label

  # == Views ===============================================================
  view :all
  view :by_company, emit_key: :company_id
  view :by_reference, emit_key: [:company_id, :reference]

  # == Callbacks ============================================================
  def self.find_by(reference, company_id)
    MissionStatusType.by_reference(key: [company_id, reference]).to_a.first
  end

  def self.first
    MissionStatusType.all.to_a.first
  end

  def self.last
    MissionStatusType.all.to_a.last
  end

  # == Class Methods ========================================================

  # == Instance Methods =====================================================

  include TouchableConcern

  private

  def company_id_immutable
    if company_id_changed?
      errors.add(:company_id, I18n.t('couchbase.errors.models.mission_status_type.company_id_immutable'))
    end
  end
end

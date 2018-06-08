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
#   "type": "user_settings",
#   "user_id": "user:id",
#   "company_id": "company:id",
#   "name": "route 1",
#   "date" : "2017-08-23T18:43:56.150Z",
#   "external_ref" : "XXXXX_XXXXX_XXXX_XXXXX",
#   "create_at": "2017-08-23T18:43:56.150Z",
#   "updated_at": "2017-08-23T19:56:01.150Z",
# }
#

class Route < ApplicationRecord

  # == Attributes ===========================================================
  # This value is automatically set by set_sync_user callback
  attribute :external_ref, type: String
  attribute :sync_user, type: String
  attribute :name, type: String
  attribute :date
  attribute :archived

  # == Extensions ===========================================================
  include TouchableConcern
  include AutomaticDateConcern

  # == Relationships ========================================================
  belongs_to :company
  belongs_to :user

  has_many :missions, dependent: :destroy

  # == Validations ==========================================================
  validates_presence_of :external_ref
  validate :external_ref_immutable, on: :update
  ensure_unique [:external_ref, :company_id]

  validates_presence_of :company_id
  validate :company_id_immutable, on: :update

  validates_presence_of :user_id
  validates_presence_of :sync_user
  validates_presence_of :name
  validates_presence_of :date

  # == Views ===============================================================
  view :all
  view :by_company, emit_key: :company_id
  view :by_user, emit_key: :user_id
  view :by_external_ref, emit_key: [:company_id, :external_ref]

  # == Callbacks ============================================================
  before_validation :set_sync_user

  # == Class Methods ========================================================
  def self.find_by(id_or_external_ref, company_id = nil)
    Route.by_external_ref(key: [company_id, id_or_external_ref]).to_a.first || Route.find(id_or_external_ref)
  end

  def self.first
    Route.all.to_a.first
  end

  def self.last
    Route.all.to_a.last
  end

  # == Instance Methods =====================================================
  private

  def set_sync_user
    self.sync_user = self.user&.sync_user
  end

  def company_id_immutable
    if company_id_changed?
      errors.add(:company_id, I18n.t('couchbase.errors.models.user_settings.company_id_immutable'))
    end
  end
end

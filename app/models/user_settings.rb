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
#   "sync_user": "static"
#   "data_connection": "true"
#   "automatic_data_update": "true"
#   "map_current_position": "true"
#   "night_mode": "automatic"
# }
#

class UserSettings < ApplicationRecord

  # == Attributes ===========================================================
  # This value is automatically set by set_sync_user callback
  attribute :sync_user, type: String
  attribute :data_connection, type: Boolean
  attribute :automatic_data_update, type: Boolean
  attribute :map_current_position, type: Boolean
  attribute :night_mode, type: String

  # == Extensions ===========================================================

  # == Relationships ========================================================
  belongs_to :company
  belongs_to :user

  # == Validations ==========================================================
  validates_presence_of :company_id
  validate :company_id_immutable, on: :update

  validates_presence_of :user_id
  validates_presence_of :sync_user

  # == Views ===============================================================
  view :all
  view :by_company, emit_key: :company_id
  view :by_user, emit_key: :user_id

  # == Callbacks ============================================================
  before_validation :set_sync_user

  # == Class Methods ========================================================
  def self.find_by(id_or_sync)
    UserSettings.by_user(key: id_or_sync).to_a.first || UserSettings.find(id_or_sync)
  end

  def self.first
    UserSettings.all.to_a.first
  end

  def self.last
    UserSettings.all.to_a.last
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

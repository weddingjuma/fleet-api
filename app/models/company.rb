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
#   "type" : "company",
#   "_id" : "company_XXXXX_XXXXX_XXXX_XXXXX",
#   "name" : "mapotempo"
#   "default_mission_status_type_id" : "mission_status_type_id"
# }
#

class Company < ApplicationRecord

  # == Attributes ===========================================================
  attribute :name, type: String
  attribute :default_mission_status_type_id, type: String

  # == Extensions ===========================================================

  # == Relationships ========================================================
  has_many :users, dependent: :destroy

  has_many :missions, dependent: :destroy

  has_many :mission_status_types, dependent: :destroy

  has_many :mission_status_actions, dependent: :destroy

  has_many :user_current_locations, dependent: :destroy

  has_many :user_tracks, dependent: :destroy

  # == Validations ==========================================================
  validates_presence_of :name
  ensure_unique :name

  # == Views ===============================================================
  view :all
  view :by_name, emit_key: :name

  # == Callbacks ============================================================

  # == Class Methods ========================================================
  def self.first
    Company.all.to_a.first
  end

  def self.last
    Company.all.to_a.last
  end

  # == Instance Methods =====================================================

end

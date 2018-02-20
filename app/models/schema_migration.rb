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
#   "type": "schema_migration",
#   "migration": "TIMESTAMP_migration_name"
#   "date" : "2017-08-23T18:43:56.150Z",
# }
#

class SchemaMigration < ApplicationRecord

  # == Attributes ===========================================================
  # This value is automatically set by set_sync_user callback
  attribute :migration, type: String
  attribute :date

  # == Extensions ===========================================================

  # == Relationships ========================================================
 
  # == Validations ==========================================================
  validates_presence_of :migration
  validates_presence_of :date

  # == Views ===============================================================
  view :all
  view :by_migration, emit_key: :migration

  # == Callbacks ============================================================

  # == Class Methods ========================================================
  def self.find_by(migration)
    SchemaMigration.by_migration(key: migration).to_a.first
  end

  # == Instance Methods =====================================================
end

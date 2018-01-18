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
#   "type" : "admin",
#   "_id" : "admin_XXXXX_XXXXX_XXXX_XXXXX"
#   "name" : "admin_1",
#   "email" : "admin_1@mapotempo.com",
#   "password_hash" : "sdfsdlfkiahiuryazbrnavrb",
#   "api_key" : "G7mZpybb9yu4EhH744bAIgtt",
# }
#

class Admin < ApplicationRecord

  # == Attributes ===========================================================
  attribute :name, type: String

  attribute :email, type: String
  attribute :password_hash, type: String
  attribute :api_key, type: String

  # == Extensions ===========================================================
  include BCrypt

  # == Relationships ========================================================

  # == Validations ==========================================================
  validates_presence_of :name
  ensure_unique :name

  validates_presence_of :email
  ensure_unique :email

  validates_presence_of :password

  validate :no_special_characters

  # == Views ===============================================================
  view :all
  view :by_name, emit_key: :name
  view :by_token, emit_key: :api_key

  # == Callbacks ============================================================
  before_create :generate_api_key

  # == Class Methods ========================================================

  # == Instance Methods =====================================================
  def password
    @password ||= Password.new(self.password_hash) if self.password_hash
  end

  def password=(new_password)
    @raw_password = new_password
    @password = Password.create(new_password)
    self.password_hash = @password
  end

  private

  def no_special_characters
    if self.name !~ /^[a-zA-Z0-9_\-]*$/
      errors.add(:name, I18n.t('couchbase.errors.models.user.no_special_characters'))
    end
  end

  def generate_api_key
    api_key = loop do
      token = SecureRandom.base64.tr('+/=', 'Qrt')
      break token unless User.all.to_a.map(&:api_key).include?(token)
    end

    self.api_key = api_key
  end
end

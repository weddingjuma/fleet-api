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
#   "type" : "user",
#   "_id" : "user_XXXXX_XXXXX_XXXX_XXXXX"
#   "company_id" : "company_XXXXX_XXXXX_XXXX_XXXXX",
#   "sync_user" : "aze54az6e4az564s4f5sd4f",
#   "email" : "chauffeur_1@mapotempo.com",
#   "name" : "chauffeur_1",
#   "vehicle" : true,
#   "color": "#228b22"
#   "password_hash" : "mqsfqsdjbfhvafuysdfqfaze",
#   "api_key" : "G7mZpybb9yu4EhH744bAIgtt",
#   "roles" : [
#     "mission.creating",
#     "mission.updating",
#     "mission.deleting",
#     "user_current_location.creating",
#     "user_current_location.updating",
#     "user_track.updating"
#     "user_track.updating"
#   ]
# }
#

class User < ApplicationRecord

  # == Attributes ===========================================================
  attribute :sync_user, type: String
  attribute :name, type: String
  attribute :email, type: String
  attribute :vehicle, type: Boolean
  attribute :color, type: String
  attribute :roles, type: Array
  attribute :password_hash, type: String
  attribute :api_key, type: String

  # == Extensions ===========================================================
  include BCrypt

  # == Relationships ========================================================
  belongs_to :company

  has_many :missions

  # == Validations ==========================================================
  validates_presence_of :company_id

  validates_presence_of :sync_user
  ensure_unique :sync_user

  validates_presence_of :email
  ensure_unique :email

  validates_presence_of :name

  validates_presence_of :password, if: -> { vehicle }

  validate :no_special_characters
  validate :company_id_immutable, on: :update

  validate :role_format

  # == Views ===============================================================
  view :all
  view :by_name, emit_key: :name
  view :by_sync_user, emit_key: :sync_user
  view :by_email, emit_key: :email
  view :by_company, emit_key: :company_id
  view :by_token, emit_key: :api_key

  # == Callbacks ============================================================
  before_validation :generate_sync_user
  before_create :ensure_vehicle, :generate_api_key, :create_sync_gateway_user
  after_create :add_location_for_vehicle
  after_create :set_settings

  before_update :update_sync_user

  before_destroy :destroy_sync_user

  # == Class Methods ========================================================
  def self.find_by(id_or_sync)
    User.by_sync_user(key: id_or_sync).to_a.first || User.find(id_or_sync)
  end

  def self.first
    User.all.to_a.first
  end

  def self.last
    User.all.to_a.last
  end

  # == Instance Methods =====================================================
  def password
    @password ||= Password.new(self.password_hash) if self.password_hash
  end

  def password=(new_password)
    @raw_password = new_password
    @password = Password.create(new_password)
    self.password_hash = @password
  end

  def current_location
    UserCurrentLocation.by_user(key: self.id).to_a.first if self.vehicle
  end

  def settings
    UserSettings.by_user(key: self.id).to_a.first
  end

  private

  def ensure_vehicle
    self.vehicle = true if self.vehicle.nil?
  end

  def generate_sync_user
    # Convert user email to sha256 to generate a uniq sync_user, used for login
    self.sync_user = Digest::SHA256.hexdigest(self.email) if self.email
  end

  def no_special_characters
    if self.sync_user !~ /^[a-zA-Z0-9_\-]*$/
      errors.add(:sync_user, I18n.t('couchbase.errors.models.user.no_special_characters'))
    end
  end

  def company_id_immutable
    if company_id_changed?
      errors.add(:company_id, I18n.t('couchbase.errors.models.user.company_id_immutable'))
    end
  end

  def generate_api_key
    api_key = loop do
      token = SecureRandom.base64.tr('+/=', 'Qrt')
      break token unless User.all.to_a.map(&:api_key).include?(token)
    end

    self.api_key = api_key
  end

  def create_sync_gateway_user
    return if Rails.env.test?

    return unless self.vehicle

    # Create the user in sync gateway
    response = HTTP.post("#{Rails.configuration.x.sync_gateway_url}_user/", json: { 'name': self.sync_user, 'password': @raw_password, 'email': self.email, 'disabled': false })

    if response.code != 201
      errors.add(:base, I18n.t('couchbase.errors.models.user.sync_user'))
      throw :abort
    end
  end

  def role_format
    self.roles.each do |role|
      if role !~ /^\w+\.\w+$/
        errors.add(:roles, I18n.t('couchbase.errors.models.user.role_format'))
      end
    end if self.roles
  end

  def add_location_for_vehicle
    if self.vehicle
      UserCurrentLocation.create(user: self, company: self.company, date: Time.zone.now.strftime('%FT%T.%L%:z'), location_detail: {
        lat: nil,
        lon: nil,
        date: Time.zone.now.strftime('%FT%T.%L%:z')
      })
    end
  end

  def set_settings
    UserSettings.create(user: self, company: self.company,
                        data_connection: true,
                        automatic_data_update: true,
                        map_current_position: true,
                        night_mode: 'automatic'
    )
  end

  def update_sync_user
    return if Rails.env.test?

    return unless self.vehicle

    return unless sync_user_changed? || email_changed? || @raw_password

    response = HTTP.put("#{Rails.configuration.x.sync_gateway_url}_user/#{self.sync_user}", json: { 'name': self.sync_user, 'email': self.email, 'password': @raw_password }.compact)

    if response.code != 200
      errors.add(:base, I18n.t('couchbase.errors.models.user.update_sync_user'))
      throw :abort
    end
  end

  def destroy_sync_user
    return if Rails.env.test?

    return unless self.vehicle

    response = HTTP.delete("#{Rails.configuration.x.sync_gateway_url}_user/#{self.sync_user}")

    if response.code != 200
      errors.add(:base, I18n.t('couchbase.errors.models.user.delete_sync_user'))
      throw :abort
    end
  end
end

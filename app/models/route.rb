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
  attribute :archived_at

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

  validate :mission_bulk_validation

  # == Views ===============================================================
  view :all
  view :by_company, emit_key: :company_id
  view :by_user, emit_key: :user_id
  view :by_external_ref, emit_key: [:company_id, :external_ref]

  # == Callbacks ============================================================
  before_validation :set_sync_user
  after_save :mission_bulk_save

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
  def missions=(missions)
    self.updated_at = Time.now.to_s # Update time manualy to force route save
    @missions = missions.compact
  end

  attr_accessor :delete_missions

  def delete_missions=(value)
    self.updated_at = Time.now.to_s # Update time manualy to force route save
    @delete_missions=value
  end

  private

  def set_sync_user
    self.sync_user = self.user&.sync_user
  end

  def company_id_immutable
    if company_id_changed?
      errors.add(:company_id, I18n.t('couchbase.errors.models.user_settings.company_id_immutable'))
    end
  end

  def external_ref_immutable
    if external_ref_changed?
      errors.add(:external_ref, I18n.t('couchbase.errors.models.mission.external_ref_immutable'))
    end
  end

  def mission_bulk_validation
    if @missions and @missions.is_a? Array
      @missions.each do |m|
        if m.is_a? Mission
          m.route_id = 'fake_route_id' if !m.route_id # Fake route_id for validation
          m.validate!
        else
          raise "Found invalid type : #{m.class} during bulk action, expected #{Mission}"
        end
      end
    end
  end

  def mission_bulk_save
    bucket_name = Mission.bucket.bucket

    if(@delete_missions && self.exists?)
      update_ids = @missions ? @missions.map(&:id) : []
      existing_ids = missions.to_a.map(&:id)
      delete_ids = existing_ids - update_ids
      if delete_ids.count > 0
        Mission.bucket.n1ql.delete_from("`#{bucket_name}` as mission").where('type = "mission" and company_id = "' + user.company_id + '" and sync_user="' + user.sync_user + '" and META(mission).id in ' + delete_ids.to_s).results.to_a
      end
    end

    if @missions and @missions.is_a? Array
      dates = Set.new

      # 1) - Set route_id and collect date for placeholder
      @missions.each do |mission|
        mission.route = self
        dates.add(mission.date.to_date)
      end

      # 3) - Prepare merge query
      string_query =
      "`#{bucket_name}` as mission" +
      ' USING ' + @missions.to_json + ' as source' +
      '  ON KEY source.id' +
      '  WHEN MATCHED THEN' +
      '    UPDATE SET' +
#       '      mission.type=mission,' +
#       '      mission.company_id=source.company_id,' +
#       '      mission.external_ref=source.external_ref,'+
#       '      mission.sync_user=source.sync_user,'+
#       '      mission.mission_status_type_id=source.mission_status_type_id,' +
      '      mission.user_id=source.user_id,' +
      '      mission.sync_user=source.sync_user,' +
      '      mission.route_id=source.route_id,' +
      '      mission.name=source.name,' +
      '      mission.date=source.date,' +
      '      mission.location=source.location,' +
      '      mission.address=source.address,' +
      '      mission.comment=source.comment,' +
      '      mission.phone=source.phone,' +
      '      mission.reference=source.reference,' +
      '      mission.duration=source.duration,' +
      '      mission.time_windows=source.time_windows,' +
      '      mission.eta=source.eta,' +
      '      mission.mission_type=source.mission_type' +
      '  WHEN NOT MATCHED THEN' +
      '    INSERT {' +
      '      "type": "mission",' +
      '      "company_id": source.company_id,' +
      '      "route_id": source.route_id,' +
      '      "external_ref": source.external_ref,'+
      '      "user_id": source.user_id,'+
      '      "sync_user": source.sync_user,'+
      '      "mission_status_type_id": source.mission_status_type_id,' +
      '      "name": source.name,' +
      '      "date": source.date,' +
      '      "location": source.location,' +
      '      "address": source.address,' +
      '      "comment": source.comment,' +
      '      "phone": source.phone,' +
      '      "reference": source.reference,' +
      '      "duration": source.duration,' +
      '      "time_windows": source.time_windows,' +
      '      "mission_type": source.mission_type,' +
      '      "planned_travel_time": source.planned_travel_time,' +
      '      "planned_distance": source.planned_distance' +
      '    }'

      # 5) - Exec merge query
      Mission.bucket.n1ql.merge_into(string_query).results.to_a

      # 6) - Update placeholder (see after_save update_placeholder method on mission model)
      # Remove this when mobiles application version fully update
      dates.each do |date|
        placeholder = MissionsPlaceholder.by_date(key: [user.company_id, user.sync_user, date.strftime('%F')]).to_a.first
        placeholder = MissionsPlaceholder.new if !placeholder
        placeholder.assign_attributes(company_id: user.company_id, sync_user: user.sync_user, date: date.strftime('%F'), revision: placeholder.revision ? placeholder.revision + 1 : 0)
        placeholder.save!
      end

      self.missions.reset
    end
  end
end

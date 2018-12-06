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
#   "type" : "mission",
#   "_id" : "mission-XXXXX_XXXXX_XXXX_XXXXX"
#   "company_id" : "company-XXXXX_XXXXX_XXXX_XXXXX",
#   "external_ref" : "XXXXX_XXXXX_XXXX_XXXXX",
#   "user_id" : "user-XXXX_XXXX",
#   "route_id" : "route-XXXX_XXXX",
#   "sync_user" : "chauffeur_1",
#   "mission_status_type_id" : "mission_status_type_id",
#   "name" : "Mission-48",
#   "date" : "2017-08-23T18:43:56.150Z",
#   "location" : {
#     "lat" : "-0.5680988",
#     "lon" : " 44.8547927"
#   },
#   "picked_location" : {
#     "lat" : "-0.5680988",
#     "lon" : " 44.8547927"
#   },
#   "address" : {
#     "city" : "Bordeaux",
#     "country" : "France",
#     "detail" : "Pépinière éco-créative,",
#     "postalcode" : "33000",
#     "state" : "Gironde",
#     "street" : "9 Rue André Darbon"
#   },
#   "comment" : "Mapotempo est une startup qui édite des solutions web d’optimisation de tournées, innovantes et libres.",
#   "phone" : "0600000001",
#   "reference" : "ABCDEF",
#   "duration" : 240,
#   "time_windows" : [
#     {
#       "start" : "2017-08-23T8:00:00.000Z",
#       "end" : "2017-08-23T12:00:00.000Z"
#     }, {
#       "start" : "2017-08-23T13:00:00.000Z",
#       "end" : "2017-08-23T17:00:00.000Z"
#     }
#   ],
#   mission_type: mission,
#   planned_travel_time, 500,
#   planned_distance: 510
# }
#

class Mission < ApplicationRecord

  # == Attributes ===========================================================
  # == /!\ WARNING /!\
  # == In mission_controller_helper classes, the process_missions_create_update
  # == method update itself missions document without using Mission
  # == ApplicationRecord's model.
  # == When someone add some attributes in the Mission model it should also
  # == update the process_missions_create_update method.
  attribute :external_ref, type: String
  attribute :mission_type, type: String
  # This value is automatically set by set_sync_user callback
  attribute :sync_user, type: String
  attribute :name, type: String
  attribute :date
  attribute :eta
  attribute :eta_computed_at
  attribute :eta_computed_mode, type: String
  attribute :location, type: Hash
  attribute :address, type: Hash
  attribute :comment, type: String
  attribute :phone, type: String
  attribute :reference, type: String
  attribute :duration, type: Integer
  attribute :time_windows, type: Array
  attribute :planned_travel_time, type: Integer
  attribute :planned_distance, type: Integer
  attribute :survey_location, type: Hash
  attribute :survey_address, type: Hash

  # == Extensions ===========================================================
  include TouchableConcern
  include MissionConcern

  # == Relationships ========================================================
  belongs_to :company
  belongs_to :user
  belongs_to :route

  # optional : current mission status type
  belongs_to :mission_status_type

  # mission actions history
  has_many :mission_actions

  # == Validations ==========================================================
  validates_presence_of :company_id
  validate :company_id_immutable, on: :update

  validates_presence_of :external_ref
  validate :external_ref_immutable, on: :update
  ensure_unique [:external_ref, :company_id]

  validates_presence_of :user_id
  validates_presence_of :sync_user

  validates_presence_of :name
  validates_presence_of :date
  validates_presence_of :location

  validates_presence_of :route_id

  validates :mission_type, presence: true

  # == Views ===============================================================
  view :all
  view :by_company, emit_key: :company_id
  view :by_user, emit_key: :user_id
  view :by_sync_user, emit_key: :sync_user
  view :by_external_ref, emit_key: [:company_id, :external_ref]

  # == Callbacks ============================================================
  before_validation :set_sync_user, :set_workflow

  after_save :update_placeholder

  before_destroy :destroy_mission_actions

  # == Class Methods ========================================================
  def self.find_by(id_or_external_ref, company_id = nil)
    Mission.by_external_ref(key: [company_id, id_or_external_ref]).to_a.first || Mission.find(id_or_external_ref)
  end

  def self.first
    Mission.all.to_a.first
  end

  def self.last
    Mission.all.to_a.last
  end

  def self.filter_by_date(user_id, end_date, start_date = nil)
    missions = Mission.by_user(key: user_id).to_a

    missions.select do |mission|
      mission_date = mission.date.send(end_date.is_a?(Time) || start_date.is_a?(Time) ? :to_time : :to_date)

      if start_date
        mission_date >= start_date && mission_date <= end_date
      else
        mission_date <= end_date
      end
    end
  end

  def self.filter_company_by_date(company_id, end_date, start_date = nil)
    missions = Mission.by_company(key: company_id).to_a

    missions.select do |mission|
      mission_date = mission.date.send(end_date.is_a?(Time) || start_date.is_a?(Time) ? :to_time : :to_date)

      if start_date
        mission_date >= start_date && mission_date <= end_date
      else
        mission_date <= end_date
      end
    end
  end

  def compute_eta(last_known_location, last_known_time, router_params, timezone = nil)
    Time.use_zone(timezone || 'GMT') do
      lag = Time.zone.now - last_known_time
      route = Rails.application.config.router.compute_batch(
          Rails.application.config.router_url,
          router_params[:mode], router_params[:dimension],
          [last_known_location + [self.location['lat'], self.location['lon']]],
          router_params.except(:mode, :dimension).merge(geometry: false, traffic: true)
        )
      self.eta = Time.zone.now + route[0][1] - lag
      self.eta_computed_mode = router_params.slice(:mode, :dimension).values.join('_')
    end
  end

  # == Instance Methods =====================================================

  private

  def set_sync_user
    self.sync_user = self.user&.sync_user
  end

  def set_workflow
    # Set mission_status_type_id to the mission
    WorkflowMissionManager.init_workflow(self)
  end

  def company_id_immutable
    if company_id_changed?
      errors.add(:company_id, I18n.t('couchbase.errors.models.mission.company_id_immutable'))
    end
  end

  def external_ref_immutable
    if external_ref_changed?
      errors.add(:external_ref, I18n.t('couchbase.errors.models.mission.external_ref_immutable'))
    end
  end

  def update_placeholder
    placeholder = MissionsPlaceholder.find_by_mission(self) || MissionsPlaceholder.new
    placeholder.assign_attributes(company_id: self.company_id, sync_user: self.sync_user, date: self.date.to_date.strftime('%F'), revision: placeholder.revision ? placeholder.revision + 1 : 0)
    placeholder.save!
  end

  def destroy_mission_actions
    self.mission_actions.map(&:destroy)
  end

end

# == Schema Information
#
# {
#   "type" : "missions_placeholder",
#   "_id" : "missions_placeholder_XXXXX_XXXXX_XXXX_XXXXX"
#   "company_id" : "company_XXXXX_XXXXX_XXXX_XXXXX",
#   "sync_user" : "chauffeur_1",
#   "date" : "2017-08-23",
#   "revision" : "0"
# }
#

class MissionsPlaceholder < ApplicationRecord

  # == Attributes ===========================================================
  attribute :sync_user, type: String
  attribute :date
  attribute :revision

  # == Extensions ===========================================================

  # == Relationships ========================================================
  belongs_to :company

  # == Validations ==========================================================
  validates_presence_of :company_id
  validate :company_id_immutable, on: :update

  validates_presence_of :sync_user
  validate :sync_user_immutable, on: :update

  validates_presence_of :date
  validate :date_format

  # == Views ===============================================================
  view :all
  view :by_company, emit_key: :company_id
  view :by_sync_user, emit_key: [:company_id, :sync_user]
  view :by_date, emit_key: [:company_id, :sync_user, :date]

  # == Callbacks ============================================================

  # == Class Methods ========================================================
  def self.find_by(date_or_id, sync_user = nil, company_id = nil)
    sync_user && company_id ? MissionsPlaceholder.by_date(key: [company_id, sync_user, date_or_id]).to_a.first : MissionsPlaceholder.find(date_or_id)
  end

  def self.find_by_mission(mission)
    MissionsPlaceholder.by_date(key: [mission.company_id, mission.sync_user, mission.date.to_date.strftime('%F')]).to_a.first
  end

  def self.first
    MissionsPlaceholder.all.to_a.first
  end

  # == Instance Methods =====================================================

  private

  def company_id_immutable
    if company_id_changed?
      errors.add(:company_id, I18n.t('couchbase.errors.models.missions_placeholder.company_id_immutable'))
    end
  end

  def sync_user_immutable
    if sync_user_changed?
      errors.add(:sync_user, I18n.t('couchbase.errors.models.missions_placeholder.sync_user_immutable'))
    end
  end

  def date_format
    if date_changed? && date !~ /\A\d{4}-\d{2}-\d{2}\z/
      errors.add(:date, I18n.t('couchbase.errors.models.missions_placeholder.date_format'))
    end
  end
end

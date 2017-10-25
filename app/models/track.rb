# == Schema Information
#
# {
#   "user_id": "user:id",
#   "company_id": "company:id",
#   "sync_user": "user_name",
#   "date": "2017-08-23T18:43:56.150+02:00",
#   "locationDetails": [
#     {
#       "lat": 0,
#       "lon": 3,
#       "date": "2017-08-23T18:43:56.150+02:00",
#       "accuracy": 3,
#       "speed": 351,
#       "bearing": 60,
#       "elevation": 4000,
#       "signalStrength": 100,
#       "cid": 2,
#       "lac": 5,
#       "mcc": 456,
#       "mnc": 789
#     }
#   ]
# }
#

class Track < ApplicationRecord

  # == Attributes ===========================================================
  # This value is automatically set by set_sync_user callback
  attribute :sync_user, type: String
  attribute :name, type: String
  attribute :date
  attribute :locationDetails, type: Array

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

  # == Instance Methods =====================================================

  private

  def set_sync_user
    self.sync_user = self.user&.sync_user
  end

  def company_id_immutable
    if company_id_changed?
      errors.add(:company_id, I18n.t('couchbase.errors.models.current_location.company_id_immutable'))
    end
  end
end

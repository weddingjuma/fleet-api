# == Schema Information
#
# {
#   "type": "mission_status",
#   "company_id": "company_XXXXX",
#   "mission_id": "mission_XXXXX",
#   "mission_status_type_id" : "mission_status_type_XXXX",
#   "date": "2017-08-23T18:43:56.150Z",
#   "description": "description of the mission status"
# }
#

class MissionStatus < ApplicationRecord

  # == Attributes ===========================================================
  attribute :date
  attribute :description, type: String

  # == Extensions ===========================================================

  # == Relationships ========================================================
  belongs_to :company
  belongs_to :mission
  belongs_to :mission_status_type

  # == Validations ==========================================================
  validates_presence_of :company_id
  validate :company_id_immutable, on: :update

  validates_presence_of :mission_id
  validates_presence_of :mission_status_type_id

  # == Views ===============================================================
  view :all
  view :by_company, emit_key: :company_id

  # == Callbacks ============================================================

  # == Class Methods ========================================================

  # == Instance Methods =====================================================

  private

  def company_id_immutable
    if company_id_changed?
      errors.add(:company_id, I18n.t('couchbase.errors.models.mission_status.company_id_immutable'))
    end
  end
end

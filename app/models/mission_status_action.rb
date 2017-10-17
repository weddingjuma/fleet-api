# == Schema Information
#
# {
#   "type": "mission_status_action",
#   "_id": "status_action-XXXX"
#   "company_id": "company_XXXXX_XXXXX_XXXX_XXXXX",
#   "previous_mission_status_type_id": "status_pending"
#   "next_mission_status_type_id": "status_completed"
#   "label": "To pending",
#   "group": "default"
# }
#


class MissionStatusAction < ApplicationRecord

  # == Attributes ===========================================================
  attribute :group, type: String
  attribute :label, type: String

  # == Extensions ===========================================================

  # == Relationships ========================================================
  belongs_to :company

  belongs_to :previous_mission_status_type,
             class_name: MissionStatusType
  belongs_to :next_mission_status_type,
             class_name: MissionStatusType

  # == Validations ==========================================================
  validates_presence_of :company_id
  validate :company_id_immutable, on: :update

  validates_presence_of :previous_mission_status_type_id
  validates_presence_of :next_mission_status_type_id

  validates_presence_of :label

  # == Views ===============================================================
  view :all
  view :by_company, emit_key: :company_id

  # == Callbacks ============================================================

  # == Class Methods ========================================================

  # == Instance Methods =====================================================

  private

  def company_id_immutable
    if company_id_changed?
      errors.add(:company_id, I18n.t('couchbase.errors.models.mission_status_type.company_id_immutable'))
    end
  end
end

# == Schema Information
#
# {
#   "type": "mission_status_type",
#   "_id": "status_completed:lalal"
#   "company_id": "company_XXXXX_XXXXX_XXXX_XXXXX",
#   "label": "Completed",
#   "color": "#228b22"
# }
#


class MissionStatusType < ApplicationRecord

  # == Attributes ===========================================================
  attribute :color, type: String
  attribute :label, type: String

  # == Extensions ===========================================================

  # == Relationships ========================================================
  belongs_to :company

  has_many :related_missions,
           foreign_key: :previous_mission_status_type_id,
           through: :mission_status_action,
           through_key: :next_mission_status_type_id,
           class_name: MissionStatusType

  # == Validations ==========================================================
  validates_presence_of :company_id
  validate :company_id_immutable, on: :update

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

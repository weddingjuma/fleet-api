# == Schema Information
#
# {
#   "type" : "company",
#   "_id" : "company_XXXXX_XXXXX_XXXX_XXXXX",
#   "name" : "mapotempo"
# }
#

class Company < ApplicationRecord

  # == Attributes ===========================================================
  attribute :name, type: String

  # == Extensions ===========================================================

  # == Relationships ========================================================
  has_many :users, dependent: :destroy

  has_many :missions, dependent: :destroy

  has_many :mission_status_types, dependent: :destroy

  has_many :mission_status_actions, dependent: :destroy

  # == Validations ==========================================================
  validates_presence_of :name

  # == Views ===============================================================
  view :all
  view :by_name, emit_key: :name

  # == Callbacks ============================================================

  # == Class Methods ========================================================

  # == Instance Methods =====================================================

end

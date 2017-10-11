# == Schema Information
#
# {
#   "type" : "mission",
#   "_id" : "mission_XXXXX_XXXXX_XXXX_XXXXX"
#   "company_id" : "company_XXXXX_XXXXX_XXXX_XXXXX",
#   "mission_status_type_id" : "mission_status_type_id",
#   "address" : {
#     "city" : "Bordeaux",
#     "country" : "France",
#     "detail" : "Pépinière éco-créative,",
#     "postalcode" : "33000",
#     "state" : "Gironde",
#     "street" : "9 Rue André Darbon"
#   },
#   "comment" : "Mapotempo est une startup qui édite des solutions web d’optimisation de tournées, innovantes et libres.",
#   "date" : "2017-08-23T18:43:56.150Z",
#   "location" : {
#     "lat" : "-0.5680988",
#     "lon" : " 44.8547927"
#   },
#   "name" : "Mission-48",
#   "owners" : ["chauffeur_1"],
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
#   ]
# }
#

class Mission < ApplicationRecord

  # == Attributes ===========================================================
  attribute :address, type: Hash
  attribute :comment, type: String
  attribute :date
  attribute :location, type: Hash
  attribute :name, type: String
  attribute :owners, type: Array
  attribute :phone, type: String
  attribute :reference, type: String
  attribute :duration, type: Integer
  attribute :time_windows, type: Array

  # == Extensions ===========================================================

  # == Relationships ========================================================
  belongs_to :company

  # == Validations ==========================================================
  validate :company_id_immutable, on: :update

  # == Views ===============================================================
  view :all
  view :by_company, emit_key: :company_id

  # == Callbacks ============================================================

  # == Class Methods ========================================================

  # == Instance Methods =====================================================

  private

  def company_id_immutable
    if company_id_changed?
      errors.add(:company_id, I18n.t('couchbase.errors.models.user.company_id_immutable'))
    end
  end
end

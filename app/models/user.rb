# == Schema Information
#
# {
#   "type" : "user",
#   "_id" : "user_XXXXX_XXXXX_XXXX_XXXXX"
#   "company_id" : "company_XXXXX_XXXXX_XXXX_XXXXX",
#   "user" : "chauffeur_1",
#   "roles" : [
#     "mission-update",
#     "mission-deleting",
#     "mission-creating"
#   ]
# }
#

class User < ApplicationRecord
  attribute :user, type: String
  attribute :roles, type: Array

  validates_presence_of :user

  belongs_to :company

  view :all
  view :by_user, emit_key: :user
  view :by_company, emit_key: :company_id
end

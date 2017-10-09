# == Schema Information
#
# {
#   "type" : "company",
#   "_id" : "company_XXXXX_XXXXX_XXXX_XXXXX",
#   "name" : "mapotempo"
# }
#

class Company < ApplicationRecord
  attribute :name, type: String

  validates_presence_of :name

  has_many :users, dependent: :destroy

  has_many :missions, dependent: :destroy

  view :all
  view :by_name, emit_key: :name
end

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

  # == Attributes ===========================================================
  attribute :user, type: String
  attribute :roles, type: Array

  attribute :email, type: String
  attribute :password_hash, type: String
  attribute :api_key, type: String

  # == Extensions ===========================================================
  include BCrypt

  # == Relationships ========================================================
  belongs_to :company

  # == Validations ==========================================================
  validates_presence_of :user
  ensure_unique :user

  validates_presence_of :email
  ensure_unique :email

  validates_presence_of :password

  validate :no_special_characters
  validate :company_id_immutable, on: :update

  # == Views ===============================================================
  view :all
  view :by_user, emit_key: :user
  view :by_company, emit_key: :company_id
  view :by_token, emit_key: :api_key

  # == Callbacks ============================================================
  before_create :generate_api_key, :generate_sync_user

  # == Class Methods ========================================================

  # == Instance Methods =====================================================
  def password
    @password ||= Password.new(self.password_hash) if self.password_hash
  end

  def password=(new_password)
    @raw_password = new_password
    @password = Password.create(new_password)
    self.password_hash = @password
  end

  private

  def no_special_characters
    if self.user !~ /^[a-zA-Z0-9_\-]*$/
      errors.add(:user, I18n.t('couchbase.errors.models.user.no_special_characters'))
    end
  end

  def company_id_immutable
    if company_id_changed?
      errors.add(:company_id, I18n.t('couchbase.errors.models.user.company_id_immutable'))
    end
  end

  def generate_api_key
    api_key = loop do
      token = SecureRandom.base64.tr('+/=', 'Qrt')
      break token unless User.all.to_a.map(&:api_key).include?(token)
    end

    self.api_key = api_key
  end

  def generate_sync_user
    return if Rails.env.test?

    response = HTTP.post("#{Rails.configuration.x.sync_gateway_url}_user/", :json => { 'name': self.user, 'password': @raw_password, 'email': self.email, 'disabled': true })

    if response.code != 201
      errors.add(:base, I18n.t('couchbase.errors.models.user.sync_user'))
      throw :abort
    end
  end
end

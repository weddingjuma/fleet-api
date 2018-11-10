# Copyright © Mapotempo, 2017
#
# This file is part of Mapotempo.
#
# Mapotempo is free software. You can redistribute it and/or
# modify since you respect the terms of the GNU Affero General
# Public License as published by the Free Software Foundation,
# either version 3 of the License, or (at your option) any later version.
#
# Mapotempo is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the Licenses for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with Mapotempo. If not, see:
# <http://www.gnu.org/licenses/agpl.html>
#
class ApplicationController < ActionController::API
  include ActionController::Serialization

  include ActionController::HttpAuthentication::Token::ControllerMethods

  # Handle exceptions
  rescue_from StandardError, with: :server_error
  rescue_from ActionController::InvalidAuthenticityToken, with: :server_error
  rescue_from Libcouchbase::Error::KeyNotFound, with: :not_found_error
  rescue_from ActionController::RoutingError, with: :not_found_error
  rescue_from AbstractController::ActionNotFound, with: :not_found_error
  rescue_from ActionController::UnknownController, with: :not_found_error
  rescue_from ActionController::UnknownFormat, with: :not_found_error

  include Pundit
  rescue_from Pundit::NotDefinedError, with: :user_not_authorized
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from Pundit::AuthorizationNotPerformedError, with: :user_not_authorized

  # Add a before_action to authenticate all requests.
  # Move this to subclassed controllers if you only
  # want to authenticate certain methods.
  before_action :authenticate

  protected

  # Authenticate the user with token based authentication
  # Check first if it's admin
  def authenticate
    authenticate_token || render_unauthorized
  end

  def authenticate_token
    if !request.headers['Authorization'].blank? && request.headers['Authorization'] !~ /^Token token=/
      request.headers['Authorization'] = "Token token=#{request.headers['Authorization']}"
    end

    authenticate_with_http_token do |token, _options|
      @current_user = User.by_token(key: token).to_a.first
    end
  end

  def authenticate_admin
    authenticate_admin_token || render_unauthorized
  end

  def authenticate_admin_token
    if !request.headers['Authorization'].blank? && request.headers['Authorization'] !~ /^Token token=/
      request.headers['Authorization'] = "Token token=#{request.headers['Authorization']}"
    end

    authenticate_with_http_token do |token, _options|
      @current_admin = Admin.by_token(key: token).to_a.first
    end
  end

  def render_unauthorized(realm = 'Application')
    self.headers['WWW-Authenticate'] = %(Token realm="#{realm.gsub(/"/, '')}")
    render json: { errors: I18n.t('authentication.bad_credentials') }, status: :unauthorized
  end

  def pundit_user
    @current_user || @current_admin
  end

  def user_not_authorized(exception)
    # Clear the previous response body to avoid a DoubleRenderError
    self.response_body = nil
    @_response_body = nil

    message = if exception.respond_to?(:policy) && exception.respond_to?(:query)
                policy_name = exception.policy.class.to_s.underscore
                policy_type = exception.query

                I18n.t("#{policy_name}.#{policy_type}", scope: 'pundit', default: :default)
              else
                I18n.t('error.not_found')
              end

    render json: { errors: message }.to_json, status: :not_found
  end

  def not_found_error(exception)
    # Rails.logger.fatal(exception.class.to_s + ' : ' + exception.to_s)
    # Rails.logger.fatal(exception.backtrace.join("\n"))

    render json: { error: I18n.t('error.not_found') }, status: :not_found
  end

  def server_error(exception)
    Rails.logger.fatal(exception.class.to_s + ' : ' + exception.to_s)
    Rails.logger.fatal(exception.backtrace.join("\n"))

    raise if Rails.env.development?

    render json: { error: I18n.t('error.internal_error') }, status: :internal_server_error
  end
end

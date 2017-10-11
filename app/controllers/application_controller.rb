class ApplicationController < ActionController::API
  include ActionController::Serialization
  include ActionController::HttpAuthentication::Token::ControllerMethods

  # Add a before_action to authenticate all requests.
  # Move this to subclassed controllers if you only
  # want to authenticate certain methods.
  before_action :authenticate

  protected

  # Authenticate the user with token based authentication
  def authenticate
    authenticate_token || render_unauthorized
  end

  def authenticate_token
    authenticate_with_http_token do |token, _options|
      @current_user = User.by_token(key: token).to_a.first
    end
  end

  def render_unauthorized(realm = 'Application')
    self.headers['WWW-Authenticate'] = %(Token realm="#{realm.gsub(/"/, '')}")
    render json: { errors: I18n.t('authentication.bad_credentials') }, status: :unauthorized
  end
end

require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
# require "active_record/railtie"
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
require 'action_cable/engine'
# require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module MapotempoFleet
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    # Application config
    config.middleware.use Rack::Config do |env|
      env['api.tilt.root'] = Rails.root.join 'app', 'api', 'views'
    end

    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '*', headers: :any, methods: [:get, :post, :options, :put, :delete, :patch]
      end
    end

    # Json adapter for serializers
    config.paths.add 'app/serializers', eager_load: true
    ActiveModel::Serializer.config.adapter = :json
    ActiveModel::Serializer.config.default_includes = '**'

    # Swagger configuration
    config.x.swagger_docs_base_path = 'http://localhost:3000/'
    config.x.api_contact_email = 'tech@mapotempo.com'
    config.x.api_contact_url = 'https://github.com/Mapotempo/mapotempo-web'
  end
end

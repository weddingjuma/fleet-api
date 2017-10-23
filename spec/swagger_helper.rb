require 'rails_helper'

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's confiugred to server Swagger from the same folder
  config.swagger_root = Rails.root.to_s + '/swagger'

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:to_swagger' rake task, the complete Swagger will
  # be generated at the provided relative path under swagger_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a swagger_doc tag to the
  # the root example_group in your specs, e.g. describe '...', swagger_doc: 'v2/swagger.json'
  config.swagger_docs = {
    'v1/swagger.json' => {
      swagger: '2.0',
      info: {
        title: 'API V1',
        version: 'v1',
        contact_email: MapotempoFleet::Application.config.x.api_contact_email,
        contact_url: MapotempoFleet::Application.config.x.api_contact_url,
        license: 'GNU Affero General Public License 3',
        license_url: 'https://raw.githubusercontent.com/Mapotempo/mapotempo-web/master/LICENSE',
        description: ''
      },
      definitions: {
        location: {
          type: 'object',
          properties: {
            lat: { type: :string },
            lon: { type: :string }
          }
        },
        address: {
          type: 'object',
          properties: {
            city: { type: :string },
            country: { type: :string },
            detail: { type: :string },
            postalcode: { type: :string },
            state: { type: :string },
            street: { type: :string }
          }
        },
        time_windows: {
          type: 'array',
          items: {
            type: 'object',
            properties: {
              start: { type: :string },
              end: { type: :string }
            }
          }
        },
        user_required: {
          type: 'object',
          properties: {
            sync_user: { type: :string },
            email: { type: :string },
            password: { type: :string },
            roles: { type: :array, items: { type: :string } }
          },
          required: %w(sync_user email password)
        },
        user: {
          type: 'object',
          properties: {
            sync_user: { type: :string },
            email: { type: :string },
            password: { type: :string },
            roles: { type: :array, items: { type: :string } }
          }
        },
        mission_required: {
          type: :object,
          properties: {
            name: { type: :string },
            date: { type: :string },
            location: { '$ref': '#/definitions/location' },
            comment: { type: :string },
            phone: { type: :string },
            reference: { type: :string },
            duration: { type: :number },
            address: { '$ref': '#/definitions/address' },
            time_windows: { '$ref': '#/definitions/time_windows' }
          },
          required: %w(name date location)
        },
        mission: {
          type: :object,
          properties: {
            name: { type: :string },
            date: { type: :string },
            location: { '$ref': '#/definitions/location' },
            comment: { type: :string },
            phone: { type: :string },
            reference: { type: :string },
            duration: { type: :number },
            address: { '$ref': '#/definitions/address' },
            time_windows: { '$ref': '#/definitions/time_windows' }
          }
        }
      },
      paths: {},
      basePath: '/api/v1',
      securityDefinitions: {
        apiKey: {
          type: :apiKey,
          name: 'Authorization',
          in: :header
        }
      }
    }
  }
end

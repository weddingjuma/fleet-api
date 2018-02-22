require 'rails_helper'

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to server Swagger from the same folder
  config.swagger_root = Rails.root.to_s + '/swagger'

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:to_swagger' rake task, the complete Swagger will
  # be generated at the provided relative path under swagger_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a swagger_doc tag to the
  # the root example_group in your specs, e.g. describe '...', swagger_doc: 'v2/swagger.json'
  config.swagger_docs = {
    '0.1/swagger.json' => {
      swagger: '2.0',
      info: {
        title: 'API v0.1',
        version: 'v0.1',
        contact: {
          name: 'Mapotempo',
          email: MapotempoFleet::Application.config.x.api_contact_email,
          url: MapotempoFleet::Application.config.x.api_contact_url,
        },
        license: {
          name: 'GNU Affero General Public License 3',
          url: 'https://raw.githubusercontent.com/Mapotempo/fleet-api/master/LICENSE',
        },
        description: '
## Overview
The purpose of this API is to be an interface to Couchbase/SyncGateway and ease communication with mobile.

## Model
Model is structured around three majors concepts: Company, User and Mission.
* `Company`: main object for all other elements, all models must have a reference to a company. The Company has many users, each user has his own `api_key` to make API call. To create or mutate a company, an `admin` account must be used with its own API key.

* `User`: user can make API call (through an API key) or connect to a mobile device.
  * Each `user` has a `current location` which tracks mobile location. The location s updated only by the mobile.
  * All users from a company, share common settings through `user settings` model.
  * For mobile be able to update theses models (through SyncGateway), user must have declared roles. The default roles are: mission.updating, mission.deleting, mission_status.creating, mission_status.updating, mission_status.deleting, user_settings.creating, user_settings.updating, user_current_location.creating, user_current_location.updating, user_track.creating, user_track.updating.

* `Mission`: describe the mission that the user must realize.
  * Each `Mission` have an associated `mission status type` which describe its current state.
  * To switch to another status, a `mission status action` is used to declare the links between statuses.
  * Finally, to keep mission status history, each `mission` has many `mission status`.
  * Due to the SyncGateway process, a `mission placeholder` is created or updated each time a mission is saved to keep mobile in a correct sync state. This model must not be called directly.

In order to know the next status available, a default workflow is defined when creating a company. It follows this pattern:
* `To do` => `In progress`
* `To do` => `Uncompleted`

* `In progress` => `To do`
* `In progress` => `Completed`
* `In progress` => `Uncompleted`

* `Uncompleted` => `To do`

## Technical access
### Swagger descriptor
This REST API is described with Swagger. The Swagger descriptor defines the request end-points, the parameters and the return values. The API can be addressed by HTTP request or with a generated client using the Swagger descriptor.
### API key
All access to the API are subject to an `api_key` parameter in order to authenticate the user. This parameter must be sent in header with the following form: `"Token token=user_api_key"`
### Return
The API supports one return format: `json`.
'
      },
      definitions: {
        company: {
          type: 'object',
          properties: {
            name: { type: :string }
          }
        },
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
            name: { type: :string },
            email: { type: :string },
            password: { type: :string },
            roles: { type: :array, items: { type: :string } }
          },
          required: %w(sync_user email password)
        },
        user: {
          type: 'object',
          properties: {
            name: { type: :string },
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
            time_windows: { '$ref': '#/definitions/time_windows' },
            mission_type: {
              type: :string,
              enum: %w(mission stop start pause)
            }
          },
          required: %w(name date location)
        },
        mission: {
          type: 'object',
          properties: {
            name: { type: :string },
            date: { type: :string },
            location: { '$ref': '#/definitions/location' },
            comment: { type: :string },
            phone: { type: :string },
            reference: { type: :string },
            duration: { type: :number },
            address: { '$ref': '#/definitions/address' },
            time_windows: { '$ref': '#/definitions/time_windows' },
            mission_type: {
              type: :string,
              enum: %w(mission stop start pause)
            }
          }
        }
      },
      paths: {},
      basePath: '/api/0.1',
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

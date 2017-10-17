require 'swagger_helper'

describe 'Users API', type: :request do

  before(:all) do
    @company = create(:company, name: 'mapo-company')
    @user = User.create(
      company: @company,
      sync_user: 'mapotempo-user',
      email: 'test@mapotempo.com',
      password: 'password'
    )
    @users = create_list(:user, 5, company: @company)
    @missions = create_list(:mission, 5, company: @company, user: @user)

    @mission_status_type = create(:mission_status_type, company: @company)
    @related_status_type = create(:mission_status_type, company: @company)
    @mission_status_action = create(:mission_status_action,
                                    company: @company,
                                    previous_mission_status_type: @mission_status_type,
                                    next_mission_status_type: @related_status_type)

    @other_company = create(:company, name: 'other')
    @other_user = create(:user, company: @other_company)
    @other_missions = create_list(:mission, 3, company: @other_company, user: @other_user)
  end

  path '/users' do
    get 'Get all users' do
      tags 'Users'
      security [apiKey: []]
      produces 'application/json', 'application/xml'

      response '200', 'all users' do
        let(:Authorization) { "Token token=#{@user.api_key}" }
        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['users']).not_to be_empty
          expect(json['users'].size).to eq(6)
        end
      end

      response '401', 'bad token' do
        let(:Authorization) { "Token token='bad token'" }
        run_test!
      end
    end

    post 'Creates a user' do
      tags 'Users'
      security [apiKey: []]
      consumes 'application/json', 'application/xml'
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          sync_user: { type: :string },
          email: { type: :string },
          password: { type: :string },
          roles: { type: :array },
        },
        required: %w(sync_user email password)
      }

      response '200', 'user mission created' do
        let(:Authorization) { "Token token=#{@user.api_key}" }
        let(:user) { { sync_user: 'user_name', password: 'password', email: 'user@mapotempo.com', roles: ['mission-creating', 'mission-updating', 'mission-deleting'] } }
        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['user']['sync_user']).not_to be_empty
        end
      end

      response '422', 'invalid request' do
        let(:Authorization) { "Token token=#{@user.api_key}" }
        let(:user) { build(:user, sync_user: nil, password: nil).attributes }
        run_test!
      end

      response '401', 'bad token' do
        let(:Authorization) { "Token token='bad token'" }
        let(:user) { @user.attributes }
        run_test!
      end
    end
  end

  path '/users/{id}' do
    get 'Retrieves a user' do
      tags 'Users'
      security [apiKey: []]
      produces 'application/json', 'application/xml'
      parameter name: :id, in: :path, type: :string

      response '200', 'user found' do

        let(:Authorization) { "Token token=#{@user.api_key}" }
        let(:id) { @user.id }
        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['user']).not_to be_empty
          expect(json['user']['sync_user']).to eq(@user.sync_user)
        end
      end

      response '404', 'user not found' do
        describe 'invalid user' do
          let(:Authorization) { "Token token=#{@user.api_key}" }
          let(:id) { 'invalid' }
          run_test!
        end

        describe 'token from other user' do
          let(:Authorization) { "Token token=#{@other_user.api_key}" }
          let(:id) { @user.id }
          run_test!
        end
      end

      response '401', 'bad token' do
        let(:Authorization) { "Token token='bad token'" }
        let(:id) { @user.id }
        run_test!
      end
    end

    put 'Updates a user' do
      tags 'Users'
      security [apiKey: []]
      consumes 'application/json', 'application/xml'
      parameter name: :id, in: :path, type: :string
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          sync_user: { type: :string },
          email: { type: :string },
          password: { type: :string },
          roles: { type: :array }
        }
      }

      response '200', 'user updated' do
        let(:Authorization) { "Token token=#{@user.api_key}" }
        let(:id) { @users.first.id }
        let(:user) { { sync_user: 'test' } }
        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['user']).not_to be_empty
          expect(json['user']['sync_user']).to eq('test')
        end
      end

      response '422', 'invalid request' do
        let(:Authorization) { "Token token=#{@user.api_key}" }
        let(:id) { @users.first.id }
        let(:user) { @user.attributes.merge(sync_user: nil) }
        run_test!
      end

      response '401', 'bad token' do
        let(:Authorization) { "Token token='bad token'" }
        let(:id) { @users.first.id }
        let(:user) { @user.attributes }
        run_test!
      end
    end

    delete 'Deletes a user' do
      tags 'Users'
      security [apiKey: []]
      consumes 'application/json', 'application/xml'
      parameter name: :id, in: :path, type: :string

      response '200', 'user deleted' do
        let(:Authorization) { "Token token=#{@user.api_key}" }
        let(:id) { @users.last.id }
        run_test!
      end

      response '401', 'bad token' do
        let(:Authorization) { "Token token='bad token'" }
        let(:id) { @users.last.id }
        run_test!
      end
    end
  end

  path '/users/{user_id}/company' do
    get 'Retrieves a company of a user' do
      tags 'Users'
      security [apiKey: []]
      produces 'application/json', 'application/xml'
      parameter name: :user_id, in: :path, type: :string

      response '200', 'user company found' do

        let(:Authorization) { "Token token=#{@user.api_key}" }
        let(:user_id) { @user.id }
        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['company']).not_to be_empty
          expect(json['company']['name']).to eq(@company.name)
        end
      end

      response '404', 'user not found' do
        describe 'invalid user' do
          let(:Authorization) { "Token token=#{@user.api_key}" }
          let(:user_id) { 'invalid' }
          run_test!
        end

        describe 'token from other user' do
          let(:Authorization) { "Token token=#{@other_user.api_key}" }
          let(:user_id) { @user.id }
          run_test!
        end
      end

      response '401', 'bad token' do
        let(:Authorization) { "Token token='bad token'" }
        let(:user_id) { @user.id }
        run_test!
      end
    end
  end

  path '/users/{user_id}/missions' do
    get 'Retrieves all missions of a user' do
      tags 'Users'
      security [apiKey: []]
      produces 'application/json', 'application/xml'
      parameter name: :user_id, in: :path, type: :string

      response '200', 'user missions found' do

        let(:Authorization) { "Token token=#{@user.api_key}" }
        let(:user_id) { @user.id }
        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['missions']).not_to be_empty
          expect(json['missions'].size).to eq(5)
        end
      end

      response '404', 'user not found' do
        describe 'invalid user' do
          let(:Authorization) { "Token token=#{@user.api_key}" }
          let(:user_id) { 'invalid' }
          run_test!
        end

        describe 'token from other user' do
          let(:Authorization) { "Token token=#{@other_user.api_key}" }
          let(:user_id) { @user.id }
          run_test!
        end
      end

      response '401', 'bad token' do
        let(:Authorization) { "Token token='bad token'" }
        let(:user_id) { @user.id }
        run_test!
      end
    end

    post 'Creates a mission for a user' do
      tags 'Users'
      security [apiKey: []]
      consumes 'application/json', 'application/xml'
      parameter name: :user_id, in: :path, type: :string
      parameter name: :mission, in: :body, schema: {
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
      }

      response '200', 'user mission created' do
        let(:Authorization) { "Token token=#{@user.api_key}" }
        let(:user_id) { @user.id }
        let(:mission) { @missions.first.attributes }
        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['mission']).not_to be_empty
        end
      end

      response '422', 'invalid request' do
        let(:Authorization) { "Token token=#{@user.api_key}" }
        let(:user_id) { @user.id }
        let(:mission) { build(:mission, name: nil).attributes }
        run_test!
      end

      response '401', 'bad token' do
        let(:Authorization) { "Token token='bad token'" }
        let(:user_id) { @user.id }
        let(:mission) { @missions.first.attributes }
        run_test!
      end
    end
  end

  path '/users/{user_id}/missions/{id}' do
    put 'Updates a mission of a user' do
      tags 'Users'
      security [apiKey: []]
      consumes 'application/json', 'application/xml'
      parameter name: :user_id, in: :path, type: :string
      parameter name: :id, in: :path, type: :string
      parameter name: :mission, in: :body, schema: {
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

      response '200', 'user mission updated' do
        let(:Authorization) { "Token token=#{@user.api_key}" }
        let(:user_id) { @user.id }
        let(:id) { @missions.first.id }
        let(:mission) { { name: 'test' } }
        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['mission']).not_to be_empty
          expect(json['mission']['name']).to eq('test')
        end
      end

      response '422', 'invalid request' do
        let(:Authorization) { "Token token=#{@user.api_key}" }
        let(:user_id) { @user.id }
        let(:id) { @missions.first.id }
        let(:mission) { build(:mission, name: nil).attributes }
        run_test!
      end

      response '401', 'bad token' do
        let(:Authorization) { "Token token='bad token'" }
        let(:user_id) { @user.id }
        let(:id) { @missions.first.id }
        let(:mission) { @missions.first.attributes }
        run_test!
      end
    end

    delete 'Deletes a mission of a user' do
      tags 'Users'
      security [apiKey: []]
      consumes 'application/json', 'application/xml'
      parameter name: :user_id, in: :path, type: :string
      parameter name: :id, in: :path, type: :string

      response '200', 'user mission deleted' do
        let(:Authorization) { "Token token=#{@user.api_key}" }
        let(:user_id) { @user.id }
        let(:id) { @missions.last.id }
        run_test!
      end

      response '401', 'bad token' do
        let(:Authorization) { "Token token='bad token'" }
        let(:user_id) { @user.id }
        let(:id) { @missions.last.id }
        run_test!
      end
    end
  end

  path '/users/{user_id}/mission_status_types' do
    get 'Retrieves all mission status types for a user company' do
      tags 'Users'
      security [apiKey: []]
      produces 'application/json', 'application/xml'
      parameter name: :user_id, in: :path, type: :string

      response '200', 'user mission status types found' do

        let(:Authorization) { "Token token=#{@user.api_key}" }
        let(:user_id) { @user.id }
        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['mission_status_types']).not_to be_empty
          expect(json['mission_status_types'].size).to eq(2)
        end
      end

      response '404', 'user not found' do
        describe 'invalid user' do
          let(:Authorization) { "Token token=#{@user.api_key}" }
          let(:user_id) { 'invalid' }
          run_test!
        end

        describe 'token from other user' do
          let(:Authorization) { "Token token=#{@other_user.api_key}" }
          let(:user_id) { @user.id }
          run_test!
        end
      end

      response '401', 'bad token' do
        let(:Authorization) { "Token token='bad token'" }
        let(:user_id) { @user.id }
        run_test!
      end
    end

    post 'Creates a mission status type for a user' do
      tags 'Users'
      security [apiKey: []]
      consumes 'application/json', 'application/xml'
      parameter name: :user_id, in: :path, type: :string
      parameter name: :mission_status_type, in: :body, schema: {
        type: :object,
        properties: {
          label: { type: :string },
          color: { type: :string }
        },
        required: %w(label)
      }

      response '200', 'user mission status type created' do
        let(:Authorization) { "Token token=#{@user.api_key}" }
        let(:user_id) { @user.id }
        let(:mission_status_type) { { label: 'complete', color: '#123456' } }
        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['mission_status_type']).not_to be_empty
        end
      end

      response '422', 'invalid request' do
        let(:Authorization) { "Token token=#{@user.api_key}" }
        let(:user_id) { @user.id }
        let(:mission_status_type) { { label: nil } }
        run_test!
      end

      response '401', 'bad token' do
        let(:Authorization) { "Token token='bad token'" }
        let(:user_id) { @user.id }
        let(:mission_status_type) { { label: 'complete', color: '#123456' } }
        run_test!
      end
    end
  end

  path '/users/{user_id}/mission_status_types/{id}' do
    put 'Updates a mission status type of a user' do
      tags 'Users'
      security [apiKey: []]
      consumes 'application/json', 'application/xml'
      parameter name: :user_id, in: :path, type: :string
      parameter name: :id, in: :path, type: :string
      parameter name: :mission_status_type, in: :body, schema: {
        type: :object,
        properties: {
          label: { type: :string },
          color: { type: :string }
        }
      }

      response '200', 'user mission status type updated' do
        let(:Authorization) { "Token token=#{@user.api_key}" }
        let(:user_id) { @user.id }
        let(:id) { @mission_status_type.id }
        let(:mission_status_type) { { label: 'new label' } }
        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['mission_status_type']).not_to be_empty
          expect(json['mission_status_type']['label']).to eq('new label')
        end
      end

      response '422', 'invalid request' do
        let(:Authorization) { "Token token=#{@user.api_key}" }
        let(:user_id) { @user.id }
        let(:id) { @mission_status_type.id }
        let(:mission_status_type) { { label: nil } }
        run_test!
      end

      response '401', 'bad token' do
        let(:Authorization) { "Token token='bad token'" }
        let(:user_id) { @user.id }
        let(:id) { @mission_status_type.id }
        let(:mission_status_type) { @missions.first.attributes }
        run_test!
      end
    end

    delete 'Deletes a mission status type of a user' do
      tags 'Users'
      security [apiKey: []]
      consumes 'application/json', 'application/xml'
      parameter name: :user_id, in: :path, type: :string
      parameter name: :id, in: :path, type: :string

      response '200', 'user mission status type deleted' do
        let(:Authorization) { "Token token=#{@user.api_key}" }
        let(:user_id) { @user.id }
        let(:id) { @mission_status_type.id }
        run_test!
      end

      response '401', 'bad token' do
        let(:Authorization) { "Token token='bad token'" }
        let(:user_id) { @user.id }
        let(:id) { @mission_status_type.id }
        run_test!
      end
    end
  end

  path '/users/{user_id}/mission_status_actions' do
    get 'Retrieves all mission status actions for a user company' do
      tags 'Users'
      security [apiKey: []]
      produces 'application/json', 'application/xml'
      parameter name: :user_id, in: :path, type: :string

      response '200', 'user mission status actions found' do

        let(:Authorization) { "Token token=#{@user.api_key}" }
        let(:user_id) { @user.id }
        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['mission_status_actions']).not_to be_empty
          expect(json['mission_status_actions'].size).to eq(1)
        end
      end

      response '404', 'user not found' do
        describe 'invalid user' do
          let(:Authorization) { "Token token=#{@user.api_key}" }
          let(:user_id) { 'invalid' }
          run_test!
        end

        describe 'token from other user' do
          let(:Authorization) { "Token token=#{@other_user.api_key}" }
          let(:user_id) { @user.id }
          run_test!
        end
      end

      response '401', 'bad token' do
        let(:Authorization) { "Token token='bad token'" }
        let(:user_id) { @user.id }
        run_test!
      end
    end

    post 'Creates a mission status action for a user' do
      tags 'Users'
      security [apiKey: []]
      consumes 'application/json', 'application/xml'
      parameter name: :user_id, in: :path, type: :string
      parameter name: :mission_status_action, in: :body, schema: {
        type: :object,
        properties: {
          label: { type: :string },
          group: { type: :string },
          previous_mission_status_type_id: { type: :string },
          next_mission_status_type_id: { type: :string }
        },
        required: %w(label previous_mission_status_type_id next_mission_status_type_id)
      }

      response '200', 'user mission status action created' do
        let(:Authorization) { "Token token=#{@user.api_key}" }
        let(:user_id) { @user.id }
        let(:mission_status_action) { { label: 'complete', group: 'default', previous_mission_status_type_id: @mission_status_type.id, next_mission_status_type_id: @related_status_type.id } }
        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['mission_status_action']).not_to be_empty
          expect(json['mission_status_action']['previous_mission_status_type_id']).to eq(@mission_status_type.id)
          expect(json['mission_status_action']['next_mission_status_type_id']).to eq(@related_status_type.id)
        end
      end

      response '422', 'invalid request' do
        let(:Authorization) { "Token token=#{@user.api_key}" }
        let(:user_id) { @user.id }
        let(:mission_status_action) { { label: nil } }
        run_test!
      end

      response '401', 'bad token' do
        let(:Authorization) { "Token token='bad token'" }
        let(:user_id) { @user.id }
        let(:mission_status_action) { { label: 'complete', color: '#123456' } }
        run_test!
      end
    end
  end

  path '/users/{user_id}/mission_status_actions/{id}' do
    put 'Updates a mission status action of a user' do
      tags 'Users'
      security [apiKey: []]
      consumes 'application/json', 'application/xml'
      parameter name: :user_id, in: :path, type: :string
      parameter name: :id, in: :path, type: :string
      parameter name: :mission_status_action, in: :body, schema: {
        type: :object,
        properties: {
          label: { type: :string },
          group: { type: :string },
          previous_mission_status_type_id: { type: :string },
          next_mission_status_type_id: { type: :string }
        }
      }

      response '200', 'user mission status action updated' do
        let(:Authorization) { "Token token=#{@user.api_key}" }
        let(:user_id) { @user.id }
        let(:id) { @mission_status_action.id }
        let(:mission_status_action) { { label: 'new label' } }
        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['mission_status_action']).not_to be_empty
          expect(json['mission_status_action']['label']).to eq('new label')
        end
      end

      response '422', 'invalid request' do
        let(:Authorization) { "Token token=#{@user.api_key}" }
        let(:user_id) { @user.id }
        let(:id) { @mission_status_action.id }
        let(:mission_status_action) { { label: nil } }
        run_test!
      end

      response '401', 'bad token' do
        let(:Authorization) { "Token token='bad token'" }
        let(:user_id) { @user.id }
        let(:id) { @mission_status_action.id }
        let(:mission_status_action) { @missions.first.attributes }
        run_test!
      end
    end

    delete 'Deletes a mission status type of a user' do
      tags 'Users'
      security [apiKey: []]
      consumes 'application/json', 'application/xml'
      parameter name: :user_id, in: :path, type: :string
      parameter name: :id, in: :path, type: :string

      response '200', 'user mission status type deleted' do
        let(:Authorization) { "Token token=#{@user.api_key}" }
        let(:user_id) { @user.id }
        let(:id) { @mission_status_action.id }
        run_test!
      end

      response '401', 'bad token' do
        let(:Authorization) { "Token token='bad token'" }
        let(:user_id) { @user.id }
        let(:id) { @mission_status_action.id }
        run_test!
      end
    end
  end
end

require 'swagger_helper'

describe 'Users API', type: :request do

  before(:all) do
    @company = create(:company, name: 'mapo-company')
    @user = User.create(
      company: @company,
      sync_user: 'mapotempo-user',
      email: 'test@mapotempo.com',
      password: 'password',
      vehicle: false
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
      parameter name: :with_vehicle, in: :query, type: :boolean, required: false

      response '200', 'all users' do
        let(:Authorization) { "Token token=#{@user.api_key}" }

        describe 'all users' do
          run_test! do |response|
            json = JSON.parse(response.body)
            expect(json['users']).not_to be_empty
            expect(json['users'].size).to eq(6)
          end
        end

        describe 'all users associated to a vehicle' do
          let(:with_vehicle) { true }
          run_test! do |response|
            json = JSON.parse(response.body)
            expect(json['users'].size).to eq(5)
          end
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
        '$ref': '#/definitions/user_required'
      }

      response '200', 'user created' do
        let(:Authorization) { "Token token=#{@user.api_key}" }
        let(:user) {  { sync_user: 'user_name', password: 'password', email: 'user@mapotempo.com', roles: %w(mission.creating mission.updating mission.deleting) } }
        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['user']['sync_user']).not_to be_empty
        end
      end

      response '422', 'invalid request' do
        let(:Authorization) { "Token token=#{@user.api_key}" }
        let(:user) { { sync_user: 'user_name', password: nil, email: 'user@mapotempo.com', roles: %w(creating) } }
        run_test!
      end

      response '401', 'bad token' do
        let(:Authorization) { "Token token='bad token'" }
        let(:user) { { sync_user: 'user_name', password: 'password', email: 'user@mapotempo.com' } }
        run_test!
      end
    end
  end

  path '/users/{sync_user}' do
    get 'Retrieves a user' do
      tags 'Users'
      security [apiKey: []]
      produces 'application/json', 'application/xml'
      parameter name: :sync_user, in: :path, type: :string

      response '200', 'user found' do
        let(:Authorization) { "Token token=#{@user.api_key}" }

        describe 'get user with sync_user' do
          let(:sync_user) { @user.sync_user }
          run_test! do |response|
            json = JSON.parse(response.body)
            expect(json['user']).not_to be_empty
            expect(json['user']['sync_user']).to eq(@user.sync_user)
          end
        end

        describe 'get user with id' do
          let(:sync_user) { @user.id }
          run_test! do |response|
            json = JSON.parse(response.body)
            expect(json['user']).not_to be_empty
            expect(json['user']['sync_user']).to eq(@user.sync_user)
          end
        end
      end

      response '404', 'user not found' do
        describe 'invalid user' do
          let(:Authorization) { "Token token=#{@user.api_key}" }
          let(:sync_user) { 'invalid' }
          run_test!
        end

        describe 'token from other user' do
          let(:Authorization) { "Token token=#{@other_user.api_key}" }
          let(:sync_user) { @user.sync_user }
          run_test!
        end
      end

      response '401', 'bad token' do
        let(:Authorization) { "Token token='bad token'" }
        let(:sync_user) { @user.sync_user }
        run_test!
      end
    end

    put 'Updates a user' do
      tags 'Users'
      security [apiKey: []]
      consumes 'application/json', 'application/xml'
      parameter name: :sync_user, in: :path, type: :string
      parameter name: :user, in: :body, schema: {
        '$ref': '#/definitions/user_required'
      }

      response '200', 'user updated' do
        let(:Authorization) { "Token token=#{@user.api_key}" }
        let(:sync_user) { @users.second.sync_user }
        let(:user) { { sync_user: 'test' } }
        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['user']).not_to be_empty
          expect(json['user']['sync_user']).to eq('test')
        end
      end

      response '422', 'invalid request' do
        let(:Authorization) { "Token token=#{@user.api_key}" }
        let(:sync_user) { @users.third.sync_user }
        let(:user) { { sync_user: nil } }
        run_test!
      end

      response '401', 'bad token' do
        let(:Authorization) { "Token token='bad token'" }
        let(:sync_user) { @users.third.sync_user }
        let(:user) { { sync_user: 'test' } }
        run_test!
      end
    end

    delete 'Deletes a user' do
      tags 'Users'
      security [apiKey: []]
      consumes 'application/json', 'application/xml'
      parameter name: :sync_user, in: :path, type: :string

      response '200', 'user deleted' do
        let(:Authorization) { "Token token=#{@user.api_key}" }
        let(:sync_user) { @users.last.sync_user }
        run_test!
      end

      response '401', 'bad token' do
        let(:Authorization) { "Token token='bad token'" }
        let(:sync_user) { @users.last.sync_user }
        run_test!
      end
    end
  end

  path '/users/{sync_user}/company' do
    get 'Retrieves a company of a user' do
      tags 'Users'
      security [apiKey: []]
      produces 'application/json', 'application/xml'
      parameter name: :sync_user, in: :path, type: :string

      response '200', 'user company found' do

        let(:Authorization) { "Token token=#{@user.api_key}" }
        let(:sync_user) { @user.sync_user }
        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['company']).not_to be_empty
          expect(json['company']['name']).to eq(@company.name)
        end
      end

      response '404', 'user not found' do
        describe 'invalid user' do
          let(:Authorization) { "Token token=#{@user.api_key}" }
          let(:sync_user) { 'invalid' }
          run_test!
        end

        describe 'token from other user' do
          let(:Authorization) { "Token token=#{@other_user.api_key}" }
          let(:sync_user) { @user.sync_user }
          run_test!
        end
      end

      response '401', 'bad token' do
        let(:Authorization) { "Token token='bad token'" }
        let(:sync_user) { @user.sync_user }
        run_test!
      end
    end
  end

  path '/users/{sync_user}/missions' do
    get 'Retrieves all missions of a user' do
      tags 'Users'
      security [apiKey: []]
      produces 'application/json', 'application/xml'
      parameter name: :sync_user, in: :path, type: :string

      response '200', 'user missions found' do

        let(:Authorization) { "Token token=#{@user.api_key}" }
        let(:sync_user) { @user.sync_user }
        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['missions']).not_to be_empty
          expect(json['missions'].size).to eq(5)
        end
      end

      response '404', 'user not found' do
        describe 'invalid user' do
          let(:Authorization) { "Token token=#{@user.api_key}" }
          let(:sync_user) { 'invalid' }
          run_test!
        end

        describe 'token from other user' do
          let(:Authorization) { "Token token=#{@other_user.api_key}" }
          let(:sync_user) { @user.sync_user }
          run_test!
        end
      end

      response '401', 'bad token' do
        let(:Authorization) { "Token token='bad token'" }
        let(:sync_user) { @user.sync_user }
        run_test!
      end
    end

    post 'Creates a mission for a user' do
      tags 'Users'
      security [apiKey: []]
      consumes 'application/json', 'application/xml'
      parameter name: :sync_user, in: :path, type: :string
      parameter name: :mission, in: :body, schema: {
        '$ref': '#/definitions/mission_required'
      }

      response '200', 'user mission created' do
        let(:Authorization) { "Token token=#{@user.api_key}" }
        let(:sync_user) { @user.sync_user }
        let(:mission) { build(:mission, external_ref: 'other_ref').attributes }
        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['mission']).not_to be_empty
        end
      end

      response '422', 'invalid request' do
        let(:Authorization) { "Token token=#{@user.api_key}" }
        let(:sync_user) { @user.sync_user }
        let(:mission) { build(:mission, name: nil).attributes }
        run_test!
      end

      response '401', 'bad token' do
        let(:Authorization) { "Token token='bad token'" }
        let(:sync_user) { @user.sync_user }
        let(:mission) { build(:mission).attributes }
        run_test!
      end
    end
  end

  path '/users/{sync_user}/missions/create_multiples' do
    post 'Creates a list of missions for a user' do
      tags 'Users'
      security [apiKey: []]
      consumes 'application/json', 'application/xml'
      parameter name: :sync_user, in: :path, type: :string
      parameter name: :mission, in: :body, schema: {
        type: :array,
        items: {
          '$ref': '#/definitions/mission_required'
        }
      }

      response '200', 'user mission created' do
        let(:Authorization) { "Token token=#{@user.api_key}" }
        let(:sync_user) { @user.sync_user }
        let(:mission) { build_list(:mission, 3, company: @company, user: @user) }
        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['missions']).not_to be_empty
          expect(json['missions'].size).to eq(3)
        end
      end

      response '422', 'invalid request' do
        let(:Authorization) { "Token token=#{@user.api_key}" }
        let(:sync_user) { @user.sync_user }
        let(:mission) { build_list(:mission, 3, company: @company, user: @user, name: nil) }
        run_test!
      end

      response '401', 'bad token' do
        let(:Authorization) { "Token token='bad token'" }
        let(:sync_user) { @user.sync_user }
        let(:mission) { build_list(:mission, 3, company: @company, user: @user) }
        run_test!
      end
    end
  end

  path '/users/{sync_user}/missions/destroy_multiples' do
    delete 'Deletes a list of missions for a user' do
      tags 'Users'
      security [apiKey: []]
      consumes 'application/json', 'application/xml'
      parameter name: :sync_user, in: :path, type: :string
      parameter name: :ids, in: :query, type: :array, items: { type: :string }, required: true

      response '204', 'user missions deleted' do
        let(:Authorization) { "Token token=#{@user.api_key}" }
        let(:sync_user) { @user.sync_user }
        let(:ids) { @missions.last(2).map(&:id) }
        run_test!
      end

      response '401', 'bad token' do
        let(:Authorization) { "Token token='bad token'" }
        let(:sync_user) { @user.sync_user }
        let(:ids) { @missions.last(2).map(&:id) }
        run_test!
      end
    end
  end

  path '/users/{sync_user}/missions/{id}' do
    put 'Updates a mission of a user' do
      tags 'Users'
      security [apiKey: []]
      consumes 'application/json', 'application/xml'
      parameter name: :sync_user, in: :path, type: :string
      parameter name: :id, in: :path, type: :string
      parameter name: :mission, in: :body, schema: {
        '$ref': '#/definitions/mission'
      }

      response '200', 'user mission updated' do
        let(:Authorization) { "Token token=#{@user.api_key}" }
        let(:sync_user) { @user.sync_user }
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
        let(:sync_user) { @user.sync_user }
        let(:id) { @missions.first.id }
        let(:mission) { build(:mission, name: nil).attributes }
        run_test!
      end

      response '401', 'bad token' do
        let(:Authorization) { "Token token='bad token'" }
        let(:sync_user) { @user.sync_user }
        let(:id) { @missions.first.id }
        let(:mission) { @missions.first.attributes }
        run_test!
      end
    end

    delete 'Deletes a mission of a user' do
      tags 'Users'
      security [apiKey: []]
      consumes 'application/json', 'application/xml'
      parameter name: :sync_user, in: :path, type: :string
      parameter name: :id, in: :path, type: :string

      response '200', 'user mission deleted' do
        let(:Authorization) { "Token token=#{@user.api_key}" }
        let(:sync_user) { @user.sync_user }

        describe 'delete mission with external_ref' do
          let(:id) { @missions.third.external_ref }
          run_test!
        end

        describe 'delete mission with id' do
          let(:id) { @missions.second.external_ref }
          run_test!
        end
      end

      response '401', 'bad token' do
        let(:Authorization) { "Token token='bad token'" }
        let(:sync_user) { @user.sync_user }
        let(:id) { @missions.first.id }
        run_test!
      end
    end
  end

  path '/users/{sync_user}/mission_status_types' do
    get 'Retrieves all mission status types for a user company' do
      tags 'Users'
      security [apiKey: []]
      produces 'application/json', 'application/xml'
      parameter name: :sync_user, in: :path, type: :string

      response '200', 'user mission status types found' do

        let(:Authorization) { "Token token=#{@user.api_key}" }
        let(:sync_user) { @user.sync_user }
        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['mission_status_types']).not_to be_empty
          expect(json['mission_status_types'].size).to eq(2)
        end
      end

      response '404', 'user not found' do
        describe 'invalid user' do
          let(:Authorization) { "Token token=#{@user.api_key}" }
          let(:sync_user) { 'invalid' }
          run_test!
        end

        describe 'token from other user' do
          let(:Authorization) { "Token token=#{@other_user.api_key}" }
          let(:sync_user) { @user.sync_user }
          run_test!
        end
      end

      response '401', 'bad token' do
        let(:Authorization) { "Token token='bad token'" }
        let(:sync_user) { @user.sync_user }
        run_test!
      end
    end

    post 'Creates a mission status type for a user' do
      tags 'Users'
      security [apiKey: []]
      consumes 'application/json', 'application/xml'
      parameter name: :sync_user, in: :path, type: :string
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
        let(:sync_user) { @user.sync_user }
        let(:mission_status_type) { { label: 'complete', color: '#123456' } }
        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['mission_status_type']).not_to be_empty
        end
      end

      response '422', 'invalid request' do
        let(:Authorization) { "Token token=#{@user.api_key}" }
        let(:sync_user) { @user.sync_user }
        let(:mission_status_type) { { label: nil } }
        run_test!
      end

      response '401', 'bad token' do
        let(:Authorization) { "Token token='bad token'" }
        let(:sync_user) { @user.sync_user }
        let(:mission_status_type) { { label: 'complete', color: '#123456' } }
        run_test!
      end
    end
  end

  path '/users/{sync_user}/mission_status_types/{id}' do
    put 'Updates a mission status type of a user' do
      tags 'Users'
      security [apiKey: []]
      consumes 'application/json', 'application/xml'
      parameter name: :sync_user, in: :path, type: :string
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
        let(:sync_user) { @user.sync_user }
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
        let(:sync_user) { @user.sync_user }
        let(:id) { @mission_status_type.id }
        let(:mission_status_type) { { label: nil } }
        run_test!
      end

      response '401', 'bad token' do
        let(:Authorization) { "Token token='bad token'" }
        let(:sync_user) { @user.sync_user }
        let(:id) { @mission_status_type.id }
        let(:mission_status_type) { @missions.first.attributes }
        run_test!
      end
    end

    delete 'Deletes a mission status type of a user' do
      tags 'Users'
      security [apiKey: []]
      consumes 'application/json', 'application/xml'
      parameter name: :sync_user, in: :path, type: :string
      parameter name: :id, in: :path, type: :string

      response '200', 'user mission status type deleted' do
        let(:Authorization) { "Token token=#{@user.api_key}" }
        let(:sync_user) { @user.sync_user }
        let(:id) { @mission_status_type.id }
        run_test!
      end

      response '401', 'bad token' do
        let(:Authorization) { "Token token='bad token'" }
        let(:sync_user) { @user.sync_user }
        let(:id) { @mission_status_type.id }
        run_test!
      end
    end
  end

  path '/users/{sync_user}/mission_status_actions' do
    get 'Retrieves all mission status actions for a user company' do
      tags 'Users'
      security [apiKey: []]
      produces 'application/json', 'application/xml'
      parameter name: :sync_user, in: :path, type: :string

      response '200', 'user mission status actions found' do

        let(:Authorization) { "Token token=#{@user.api_key}" }
        let(:sync_user) { @user.sync_user }
        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['mission_status_actions']).not_to be_empty
          expect(json['mission_status_actions'].size).to eq(1)
        end
      end

      response '404', 'user not found' do
        describe 'invalid user' do
          let(:Authorization) { "Token token=#{@user.api_key}" }
          let(:sync_user) { 'invalid' }
          run_test!
        end

        describe 'token from other user' do
          let(:Authorization) { "Token token=#{@other_user.api_key}" }
          let(:sync_user) { @user.sync_user }
          run_test!
        end
      end

      response '401', 'bad token' do
        let(:Authorization) { "Token token='bad token'" }
        let(:sync_user) { @user.sync_user }
        run_test!
      end
    end

    post 'Creates a mission status action for a user' do
      tags 'Users'
      security [apiKey: []]
      consumes 'application/json', 'application/xml'
      parameter name: :sync_user, in: :path, type: :string
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
        let(:sync_user) { @user.sync_user }
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
        let(:sync_user) { @user.sync_user }
        let(:mission_status_action) { { label: nil } }
        run_test!
      end

      response '401', 'bad token' do
        let(:Authorization) { "Token token='bad token'" }
        let(:sync_user) { @user.sync_user }
        let(:mission_status_action) { { label: 'complete', color: '#123456' } }
        run_test!
      end
    end
  end

  path '/users/{sync_user}/mission_status_actions/{id}' do
    put 'Updates a mission status action of a user' do
      tags 'Users'
      security [apiKey: []]
      consumes 'application/json', 'application/xml'
      parameter name: :sync_user, in: :path, type: :string
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
        let(:sync_user) { @user.sync_user }
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
        let(:sync_user) { @user.sync_user }
        let(:id) { @mission_status_action.id }
        let(:mission_status_action) { { label: nil } }
        run_test!
      end

      response '401', 'bad token' do
        let(:Authorization) { "Token token='bad token'" }
        let(:sync_user) { @user.sync_user }
        let(:id) { @mission_status_action.id }
        let(:mission_status_action) { @missions.first.attributes }
        run_test!
      end
    end

    delete 'Deletes a mission status type of a user' do
      tags 'Users'
      security [apiKey: []]
      consumes 'application/json', 'application/xml'
      parameter name: :sync_user, in: :path, type: :string
      parameter name: :id, in: :path, type: :string

      response '200', 'user mission status type deleted' do
        let(:Authorization) { "Token token=#{@user.api_key}" }
        let(:sync_user) { @user.sync_user }
        let(:id) { @mission_status_action.id }
        run_test!
      end

      response '401', 'bad token' do
        let(:Authorization) { "Token token='bad token'" }
        let(:sync_user) { @user.sync_user }
        let(:id) { @mission_status_action.id }
        run_test!
      end
    end
  end
end

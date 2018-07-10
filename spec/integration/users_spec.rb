require 'swagger_helper'

describe 'Users API', type: :request do

  before(:all) do
    @company = create(:company, name: 'mapo-company')
    @user = User.create(
      company: @company,
      name: 'mapotempo-user',
      email: 'test@mapotempo.com',
      password: 'password',
      vehicle: false
    )

    @users = create_list(:user, 5, company: @company, vehicle: true)
    @route = create(:route, company: @company, user: @user, name: 'mapo-route')
    @missions = create_list(:mission, 5, company: @company, user: @user, route: @route)

    @todo_status_type = create(:mission_status_type, company: @company, label: 'To do', color: '#ff0000')
    @company.update_attribute(:default_mission_status_type_id, @todo_status_type.id)

    @other_company = create(:company, name: 'other')
    @other_user = create(:user, company: @other_company)
    @other_route = create(:route, company: @other_company, user: @other_user, name: 'mapo-route')
    @other_missions = create_list(:mission, 3, company: @other_company, user: @other_user, route: @other_route)
  end

  path '/users' do
    get 'Get all users' do
      tags 'Users'
      operationId 'getUsers'
      description 'Retrieves all users from the company of the current user'
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
      operationId 'createUser'
      description 'Create a new user in the current company'
      security [apiKey: []]
      consumes 'application/json', 'application/xml'
      parameter name: :user, in: :body, schema: {
        '$ref': '#/definitions/user_required'
      }

      response '200', 'user created' do
        let(:Authorization) { "Token token=#{@user.api_key}" }
        let(:user) {  { name: 'user_name', phone: '0000000000', email: 'user@mapotempo.com', password: 'password', roles: %w(mission.creating mission.updating mission.deleting) } }
        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['user']['name']).not_to be_empty
          expect(json['user']['sync_user']).not_to be_empty
          expect(json['user']['phone']) == '0000000000'
        end
      end

      response '422', 'invalid request' do
        let(:Authorization) { "Token token=#{@user.api_key}" }
        let(:user) { { name: 'user_name', password: nil, email: 'user@mapotempo.com', roles: %w(creating) } }
        run_test!
      end

      response '401', 'bad token' do
        let(:Authorization) { "Token token='bad token'" }
        let(:user) { { name: 'user_name', password: 'password', email: 'user@mapotempo.com' } }
        run_test!
      end
    end
  end

  path '/users/{sync_user}' do
    get 'Retrieves a user' do
      tags 'Users'
      operationId 'getUser'
      description 'Retrieves a user in the current company'
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
      operationId 'updateUser'
      description 'Updates a user in the current company'
      security [apiKey: []]
      consumes 'application/json', 'application/xml'
      parameter name: :sync_user, in: :path, type: :string
      parameter name: :user, in: :body, schema: {
        '$ref': '#/definitions/user_required'
      }

      response '200', 'user updated' do
        let(:Authorization) { "Token token=#{@user.api_key}" }
        let(:sync_user) { @users.second.sync_user }
        let(:user) { { name: 'test' } }
        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['user']).not_to be_empty
          expect(json['user']['name']).to eq('test')
        end
      end

      response '422', 'invalid request' do
        let(:Authorization) { "Token token=#{@user.api_key}" }
        let(:sync_user) { @users.third.sync_user }
        let(:user) { { name: nil, sync_user: nil } }
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
      operationId 'deleteUser'
      description 'Deletes a user in the current company'
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

  path '/users/{sync_user}/current_location' do
    get 'Retrieves the current location of a user' do
      tags 'Users'
      operationId 'getUserUserCurrentLocation'
      description 'Retrieves the current location of the current user'
      security [apiKey: []]
      produces 'application/json', 'application/xml'
      parameter name: :sync_user, in: :path, type: :string

      response '200', 'user current location found' do
        let(:Authorization) { "Token token=#{@user.api_key}" }
        let(:sync_user) { @users.first.sync_user }
        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['user_current_location']).not_to be_empty
          expect(json['user_current_location']['location_detail']['lat']).to be nil
        end
      end

      response '404', 'user current location not found' do
        describe 'user is not a vehicle' do
          let(:Authorization) { "Token token=#{@user.api_key}" }
          let(:sync_user) { @user.sync_user }
          run_test!
        end

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
end

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

    @users = create_list(:user, 5, company: @company, vehicle: true)
    @missions = create_list(:mission, 5, company: @company, user: @user)

    @todo_status_type = create(:mission_status_type, company: @company, label: 'To do', color: '#ff0000')
    @company.update_attribute(:default_mission_status_type_id, @todo_status_type.id)

    @other_company = create(:company, name: 'other')
    @other_user = create(:user, company: @other_company)
    @other_missions = create_list(:mission, 3, company: @other_company, user: @other_user)
  end

  path '/users' do
    get 'Get all users' do
      tags 'Users'
      operationId 'getUsers'
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
      operationId 'getUser'
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
      operationId 'deleteUser'
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
      operationId 'getUserCompany'
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

  path '/users/{sync_user}/current_location' do
    get 'Retrieves the current location of a user' do
      tags 'Users'
      operationId 'getUserUserCurrentLocation'
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

  path '/users/{sync_user}/missions' do
    get 'Retrieves all missions of a user' do
      tags 'Users'
      operationId 'getUserMissions'
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
      operationId 'createUserMission'
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
          expect(json['mission']['mission_status_type_id']).to eq(@todo_status_type.id)
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
      operationId 'createUserMissions'
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
      operationId 'destroyUserMissions'
      security [apiKey: []]
      consumes 'application/json', 'application/xml'
      parameter name: :sync_user, in: :path, type: :string
      parameter name: :ids, in: :query, type: :array, items: { type: :string }, required: false
      parameter name: :start_date, in: :query, type: :string, required: false
      parameter name: :end_date, in: :query, type: :string, required: false

      response '204', 'user missions deleted' do
        let(:Authorization) { "Token token=#{@user.api_key}" }
        let(:sync_user) { @user.sync_user }

        describe 'delete mission by ids' do
          let(:ids) { @missions.last(2).map(&:id) }
          run_test!
        end

        describe 'delete with no missions' do
          let(:ids) { [] }
          run_test!
        end

        # describe 'delete mission by date' do
        #   let(:start_date) { Time.now.strftime('%Y-%m-%d') }
        #   let(:end_date) { Time.now.strftime('%Y-%m-%d') }
        #   run_test!
        # end
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
      operationId 'updateUserMission'
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
      operationId 'deleteUserMission'
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
end

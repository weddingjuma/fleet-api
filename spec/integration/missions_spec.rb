require 'swagger_helper'

describe 'Missions API', type: :request do

  before(:all) do
    @company = create(:company, name: 'mapo-company')
    @user = create(:user, company: @company, vehicle: false)
    @user_2 = create(:user, company: @company, vehicle: true)

    @missions = create_list(:mission, 3, user: @user, company: @company)
    @missions_2 = create_list(:mission, 2, user: @user_2, company: @company)

    @other_company = create(:company, name: 'other')
    @other_user = create(:user, company: @other_company)
    @other_missions = create_list(:mission, 2, user: @user, company: @other_company)
  end

  path '/missions' do
    get 'Get all missions' do
      tags 'Missions'
      operationId 'getMissions'
      description 'Retrieves all missions from the company of the current user'
      security [apiKey: []]
      produces 'application/json', 'application/xml'
      parameter name: :user_id, in: :query, type: :string, required: false

      response '200', 'all missions' do
        let(:Authorization) { "Token token=#{@user.api_key}" }
        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['missions']).not_to be_empty
          expect(json['missions'].size).to eq(5)
        end
      end

      response '200', 'all missions' do
        let(:Authorization) { "Token token=#{@user.api_key}" }
        let(:user_id) {@user_2.id.to_s}
        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['missions']).not_to be_empty
          expect(json['missions'].size).to eq(2)
        end
      end

      response '401', 'bad token' do
        let(:Authorization) { "Token token='invalid_token'" }
        run_test!
      end
    end

    post 'Creates a mission for a user' do
      tags 'Missions'
      operationId 'createUserMission'
      description 'Creates a mission for the current user'
      security [apiKey: []]
      consumes 'application/json', 'application/xml'
      # parameter name: :user_id, in: :query, type: :string, required: true
      parameter name: :mission, in: :body, schema: {
        '$ref': '#/definitions/mission_required'
      }

      response '200', 'user mission created' do
        let(:Authorization) { "Token token=#{@user.api_key}" }
        let(:mission) { build(:mission, external_ref: 'other_ref', user: @user).attributes }
        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['mission']).not_to be_empty
          # expect(json['mission']['mission_status_type_id']).to eq(@todo_status_type.id)
        end
      end

      response '404', 'can\'t created mission for another user company' do
        let(:Authorization) { "Token token=#{@user.api_key}" }
        let(:mission) { build(:mission, external_ref: 'other_ref_2', user: @other_user).attributes }
        run_test!
      end

      response '404', 'without user_id' do
        let(:Authorization) { "Token token=#{@user.api_key}" }
        let(:mission) { build(:mission, external_ref: 'another_ref').attributes }
        run_test!
      end

      response '422', 'invalid request' do
        let(:Authorization) { "Token token=#{@user.api_key}" }
        let(:mission) { build(:mission, name: nil, user: @user).attributes }
        run_test!
      end

      response '401', 'bad token' do
        let(:Authorization) { "Token token='bad token'" }
        let(:user_id) { @user.id }
        let(:mission) { build(:mission).attributes }
        run_test!
      end
    end
  end

  path '/missions' do
    put 'Create / Update a list of missions for a user' do
      tags 'Missions'
      operationId 'createUserMissions'
      description 'Creates a set of missions for the current user'
      security [apiKey: []]
      consumes 'application/json', 'application/xml'
      parameter name: :user_id, in: :query, type: :string, required: true
      parameter name: :mission, in: :body, schema: {
        type: :array,
        items: {
          '$ref': '#/definitions/mission_required'
        }
      }

      response '200', 'user mission created' do
        let(:Authorization) { "Token token=#{@user.api_key}" }
        let(:user_id) { @user.sync_user }
        let(:mission) { build_list(:mission, 3, company: @company, user: @user) }
        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['missions']).not_to be_empty
          expect(json['missions'].size).to eq(3)
        end
      end

      response '422', 'invalid request' do
        let(:Authorization) { "Token token=#{@user.api_key}" }
        let(:user_id) { @user.sync_user }
        let(:mission) { build_list(:mission, 3, company: @company, user: @user, name: nil) }
        run_test!
      end

      response '401', 'bad token' do
        let(:Authorization) { "Token token='bad token'" }
        let(:user_id) { @user.sync_user }
        let(:mission) { build_list(:mission, 3, company: @company, user: @user) }
        run_test!
      end
    end
  end

  path '/missions' do
    delete 'Deletes a list of missions for a user' do
      tags 'Missions'
      operationId 'destroyUserMissions'
      description 'Deletes a set of missions for the current user'
      security [apiKey: []]
      consumes 'application/json', 'application/xml'
      parameter name: :user_id, in: :query, type: :string, required: true
      parameter name: :ids, in: :query, type: :array, items: { type: :string }, required: false
      parameter name: :start_date, in: :query, type: :string, required: false
      parameter name: :end_date, in: :query, type: :string, required: false

      response '204', 'user missions deleted' do
        let(:Authorization) { "Token token=#{@user.api_key}" }
        let(:user_id) { @user.sync_user }

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
        let(:user_id) { @user.sync_user }
        let(:ids) { @missions.last(2).map(&:id) }
        run_test!
      end
    end
  end

  path '/missions/{id}' do
    put 'Updates a mission of a user' do
      tags 'Missions'
      operationId 'updateUserMission'
      description 'Updates a mission belonging to the current user'
      security [apiKey: []]
      consumes 'application/json', 'application/xml'
      parameter name: :id, in: :path, type: :string
      parameter name: :mission, in: :body, schema: {
        '$ref': '#/definitions/mission'
      }

      response '200', 'user mission updated' do
        let(:Authorization) { "Token token=#{@user.api_key}" }
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
        let(:id) { @missions.first.id }
        let(:mission) { build(:mission, name: nil).attributes }
        run_test!
      end

      response '401', 'bad token' do
        let(:Authorization) { "Token token='bad token'" }
        let(:id) { @missions.first.id }
        let(:mission) { @missions.first.attributes }
        run_test!
      end
    end

    delete 'Deletes a mission' do
      tags 'Missions'
      operationId 'deleteUserMission'
      description 'Deletes a mission belonging to the current user'
      security [apiKey: []]
      consumes 'application/json', 'application/xml'
      parameter name: :id, in: :path, type: :string

      response '200', 'user mission deleted' do
        let(:Authorization) { "Token token=#{@user.api_key}" }

        describe 'delete mission with external_ref' do
          let(:id) { @missions_2.first.external_ref }
          run_test!
        end

        describe 'delete mission with id' do
          let(:id) { @missions_2.second.external_ref }
          run_test!
        end
      end

      response '401', 'bad token' do
        let(:Authorization) { "Token token='bad token'" }
        let(:sync_user) { @user.sync_user }
        let(:id) { @missions_2.first.id }
        run_test!
      end
    end

  end
end

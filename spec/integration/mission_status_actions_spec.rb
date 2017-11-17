require 'swagger_helper'

describe 'Mission status actions API', type: :request do

  before(:all) do
    @company = create(:company, name: 'mapo-company')
    @user = create(:user, company: @company, vehicle: false)
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

  path '/mission_status_actions' do
    get 'Retrieves all mission status actions for user company' do
      tags 'Mission Status Actions'
      operationId 'getMissionStatusActions'
      security [apiKey: []]
      produces 'application/json', 'application/xml'
      parameter name: :sync_user, in: :query, type: :string, required: true

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

    post 'Creates a mission status action for user company' do
      tags 'Mission Status Actions'
      operationId 'createMissionStatusAction'
      security [apiKey: []]
      consumes 'application/json', 'application/xml'
      parameter name: :sync_user, in: :query, type: :string, required: true
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

  path '/mission_status_actions/{id}' do
    put 'Updates a mission status action for user company' do
      tags 'Mission Status Actions'
      operationId 'updateMissionStatusAction'
      security [apiKey: []]
      consumes 'application/json', 'application/xml'
      parameter name: :id, in: :path, type: :string
      parameter name: :sync_user, in: :query, type: :string, required: true
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

    delete 'Deletes a mission status type for user company' do
      tags 'Mission Status Actions'
      operationId 'deleteMissionStatusAction'
      security [apiKey: []]
      consumes 'application/json', 'application/xml'
      parameter name: :id, in: :path, type: :string
      parameter name: :sync_user, in: :query, type: :string, required: true

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

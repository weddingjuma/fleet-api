require 'swagger_helper'

describe 'Mission status types API', type: :request do

  before(:all) do
    @company = create(:company, name: 'mapo-company')
    @user = create(:user, company: @company, vehicle: false)
    @route = create(:route, company: @company, user: @user, name: 'mapo-route')
    @missions = create_list(:mission, 5, company: @company, user: @user, route: @route)

    @mission_status_type = create(:mission_status_type, company: @company)
    @related_status_type = create(:mission_status_type, company: @company)

    @other_company = create(:company, name: 'other')
    @other_user = create(:user, company: @other_company)
    @other_route = create(:route, company: @other_company, user: @other_user, name: 'mapo-route')
    @other_missions = create_list(:mission, 3, company: @other_company, user: @other_user, route: @other_route)
  end

  path '/mission_status_types' do
    get 'Retrieves all mission status types for a user' do
      tags 'Mission Status Types'
      operationId 'getMissionStatusTypes'
      description 'Retrieves all mission status types for a user'
      security [apiKey: []]
      produces 'application/json', 'application/xml'
      parameter name: :sync_user, in: :query, type: :string, required: true

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
      tags 'Mission Status Types'
      operationId 'createMissionStatusType'
      description 'Creates a mission status type for a user'
      security [apiKey: []]
      consumes 'application/json', 'application/xml'
      parameter name: :sync_user, in: :query, type: :string, required: true
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
        let(:mission_status_type) { { label: 'complete', color: '#123456',  reference: 'to_do'} }
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

  path '/mission_status_types/{id}' do
    put 'Updates a mission status type for a user' do
      tags 'Mission Status Types'
      operationId 'updateMissionStatusType'
      description 'Updates a mission status type for a user'
      security [apiKey: []]
      consumes 'application/json', 'application/xml'
      parameter name: :id, in: :path, type: :string
      parameter name: :sync_user, in: :query, type: :string, required: true
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

    delete 'Deletes a mission status type for a user' do
      tags 'Mission Status Types'
      operationId 'deleteMissionStatusType'
      description 'Deletes a mission status type for a user'
      security [apiKey: []]
      consumes 'application/json', 'application/xml'
      parameter name: :id, in: :path, type: :string
      parameter name: :sync_user, in: :query, type: :string, required: true

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
end

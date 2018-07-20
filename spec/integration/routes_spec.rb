require 'swagger_helper'

describe 'Routes API', type: :request do

  before(:all) do
    @company = create(:company, name: 'mapo-company')
    @user = create(:user, company: @company, vehicle: false)
    @route = create(:route, company: @company, user: @user, name: 'mapo-route')
    @missions = create_list(:mission, 3, user: @user, company: @company, route: @route)
    @user_2 = create(:user, company: @company, vehicle: true)
    @route_2 = create(:route, company: @company, user: @user_2, name: 'mapo-route-2')
    @missions_2 = create_list(:mission, 2, user: @user_2, company: @company, route: @route_2)

    @other_company = create(:company, name: 'other')
    @other_user = create(:user, company: @other_company)
    @other_route = create(:route, company: @other_company, user: @other_user, name: 'other')
    @other_missions = create_list(:mission, 5, user: @other_user, company: @other_company, route: @other_route)
    @other_user_2 = create(:user, company: @other_company)
    @other_route_2 = create(:route, company: @other_company, user: @other_user_2, name: 'other-2')
  end

  path '/routes' do
    get 'Get all routes' do
      tags 'Routes'
      operationId 'getRoutes'
      description 'Retrieves all routes from the company of the current user'
      security [apiKey: []]
      produces 'application/json', 'application/xml'
      parameter name: :user_id, in: :query, type: :string, required: false
      parameter name: :with_missions, in: :query, type: :boolean, required: false

      response '200', 'all routes' do
        let(:Authorization) { "Token token=#{@user.api_key}" }
        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['routes']).not_to be_empty
          expect(json['routes'].size).to eq(2)
        end
      end

      response '200', 'all routes for a user' do
        let(:Authorization) { "Token token=#{@other_user.api_key}" }
        let(:user_id) {@other_user.id.to_s}
        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['routes']).not_to be_empty
          expect(json['routes'].size).to eq(1)
        end
      end

      response '401', 'bad token' do
        let(:Authorization) { "Token token='invalid_token'" }
        run_test!
      end
    end

    post 'Creates a route for a user' do
      tags 'Routes'
      operationId 'createUserRoute'
      description 'Creates a route for the current user'
      security [apiKey: []]
      consumes 'application/json', 'application/xml'
      parameter name: :route, in: :body, schema: {
        '$ref': '#/definitions/route_required'
      }
      parameter name: :with_missions, in: :query, type: :boolean, required: false

      response '200', 'user route created' do
        let(:Authorization) { "Token token=#{@user.api_key}" }
        let(:route) { build(:route, external_ref: 'the_ref', name: 'test', date: Date.today.to_s, user: @user).attributes }
        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['route']).not_to be_empty
        end
      end

      response '200', 'user route created with multiple missions' do
        let(:Authorization) { "Token token=#{@user.api_key}" }
        let(:route) {
          route = build(:route, external_ref: 'the_ref2', name: 'test2', date: Date.today.to_s, user: @user).attributes
          route[:missions] = build_list(:mission, 3, user: @user, company: @company)
          route
        }
        let(:with_missions) {true}
        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['route']).not_to be_empty
          expect(json['route']['missions']).not_to be_empty
          expect(json['route']['missions'].size).to eq 3
        end
      end

      response '200', 'user route created with missions reallocation' do
        let(:Authorization) { "Token token=#{@user.api_key}" }
        let(:route) {
          route = build(:route, external_ref: 'the_ref3', name: 'test3', date: Date.today.to_s, user: @user).attributes
          route[:missions] = @missions_2.to_a
          route
        }
        let(:with_missions) {true}
        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['route']).not_to be_empty
          expect(json['route']['missions']).not_to be_empty
          expect(json['route']['missions'].size).to eq 2
          expect(@route_2.missions.to_a.count).to eq 0
        end
      end

      response '200', 'user route created with mission can\'t steal mission from another company' do
        let(:Authorization) { "Token token=#{@user.api_key}" }
        let(:route) {
          route = build(:route, external_ref: 'the_ref4', name: 'test4', date: Date.today.to_s, user: @user).attributes
          route[:missions] = @other_missions.to_a
          route
        }
        let(:with_missions) {true}
        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['route']).not_to be_empty
          expect(json['route']['missions']).not_to be_empty
          expect(json['route']['missions'].size).to eq 5
          expect(@other_route.missions.to_a.count).to eq 5
        end
      end

      response '404', 'can\'t created route for another user company' do
        let(:Authorization) { "Token token=#{@user.api_key}" }
        let(:route) { build(:route, external_ref: 'other_ref_2', name: 'test3', date: Date.today.to_s, user: @other_user).attributes }
        let(:with_missions) {true}
        run_test!
      end

      response '404', 'without user_id' do
        let(:Authorization) { "Token token=#{@user.api_key}" }
        let(:route) { build(:route, external_ref: 'another_ref').attributes }
        run_test!
      end

      response '422', 'invalid request - nil name' do
        let(:Authorization) { "Token token=#{@user.api_key}" }
        let(:route) { build(:route, name: nil, external_ref: 'the_ref3', date: Date.today.to_s, user: @user).attributes }
        run_test!
      end

      response '422', 'invalid request - nil date' do
        let(:Authorization) { "Token token=#{@user.api_key}" }
        let(:route) { build(:route, date: nil, external_ref: 'the_ref3', name: 'test', user: @user).attributes }
        run_test!
      end

      response '401', 'bad token' do
        let(:Authorization) { "Token token='bad token'" }
        let(:user_id) { @user.id }
        let(:route) { build(:route).attributes }
        run_test!
      end
    end
  end

  path '/routes/{id}' do
    put 'Updates a mission of a user' do
      tags 'Routes'
      operationId 'updateUserRoute'
      description 'Updates a route belonging to the current user'
      security [apiKey: []]
      consumes 'application/json', 'application/xml'
      parameter name: :id, in: :path, type: :string
      parameter name: :route, in: :body, schema: {
        '$ref': '#/definitions/route_required'
      }
      parameter name: :delete_missions, in: :query, type: :boolean, required: false
      parameter name: :with_missions, in: :query, type: :boolean, required: false

      response '200', 'route mission updated' do
        let(:Authorization) { "Token token=#{@user.api_key}" }
        let(:id) { @route.id }
        let(:route) { { name: 'test' } }
        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['route']).not_to be_empty
          expect(json['route']['name']).to eq('test')
        end
      end

      response '200', 'user route update with multiple missions update or create' do
        let(:Authorization) { "Token token=#{@user.api_key}" }
        let(:id) { @route.id }
        let(:route) { {
          name: 'test',
          missions: build_list(:mission, 5, user: @user, company: @company, route: @route).concat(@missions.to_a) }
        }
        let(:with_missions) {true}
        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['route']).not_to be_empty
          expect(json['route']['missions']).not_to be_empty
          expect(json['route']['missions'].size).to eq 8
        end
      end

      response '200', 'user route update with multiple missions update or create' do
        let(:Authorization) { "Token token=#{@user.api_key}" }
        let(:id) { @route.id }
        let(:route) { { name: 'test'} }
        let(:delete_missions) {true}
        let(:with_missions) {true}
        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['route']).not_to be_empty
          expect(json['route']['missions']).to be_empty
        end
      end

      response '422', 'invalid request' do
        let(:Authorization) { "Token token=#{@user.api_key}" }
        let(:id) { @route.id }
        let(:route) { build(:route, name: nil).attributes }
        run_test!
      end

      response '401', 'bad token' do
        let(:Authorization) { "Token token='bad token'" }
        let(:id) { @route.id }
        let(:route) { @missions.first.attributes }
        run_test!
      end
    end
  end
end

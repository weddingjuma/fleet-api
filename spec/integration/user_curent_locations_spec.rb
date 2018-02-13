require 'swagger_helper'

describe 'User current locations API', type: :request do

  before(:all) do
    @company = create(:company, name: 'mapo-company')
    @user = create(:user, company: @company, vehicle: false)

    @users = create_list(:user, 3, company: @company)

    @current_locations = @users.map do |user|
      create(:user_current_location, company: @company, user: user, location_detail: {
        lat: Random.rand(43.0..50.0),
        lon: Random.rand(-2.0..6.0),
        date: Time.now.strftime('%FT%T.%L%:z')
      })
    end

    @other_company = create(:company, name: 'other')
    @other_user = create(:user, company: @other_company)
  end

  path '/user_current_locations' do
    get 'Get all current locations' do
      tags 'Current Locations'
      operationId 'getUserCurrentLocations'
      description 'Retrieves all current locations of users from the company of the current user'
      security [apiKey: []]
      produces 'application/json', 'application/xml'

      response '200', 'all current locations' do
        let(:Authorization) { "Token token=#{@user.api_key}" }
        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['user_current_locations']).not_to be_empty
          expect(json['user_current_locations'].size).to eq(6)
        end
      end

      response '401', 'bad token' do
        let(:Authorization) { "Token token='invalid_token'" }
        run_test!
      end
    end
  end
end

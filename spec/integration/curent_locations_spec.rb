require 'swagger_helper'

describe 'Current locations API', type: :request do

  before(:all) do
    @company = create(:company, name: 'mapo-company')
    @user = create(:user, company: @company, vehicle: false)

    @users = create_list(:user, 3, company: @company)

    @current_locations = @users.map do |user|
      create(:current_location, company: @company, user: user, locationDetail: {
        lat: Random.rand(43.0..50.0),
        lon: Random.rand(-2.0..6.0),
        date: Time.now.strftime('%FT%T.%L%:z')
      })
    end

    @other_company = create(:company, name: 'other')
    @other_user = create(:user, company: @other_company)
  end

  path '/current_locations' do
    get 'Get all current locations' do
      tags 'Current Locations'
      operationId 'getCurrentLocations'
      security [apiKey: []]
      produces 'application/json', 'application/xml'

      response '200', 'all current locations' do
        let(:Authorization) { "Token token=#{@user.api_key}" }
        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['current_locations']).not_to be_empty
          expect(json['current_locations'].size).to eq(6)
        end
      end

      response '401', 'bad token' do
        let(:Authorization) { "Token token='invalid_token'" }
        run_test!
      end
    end
  end
end

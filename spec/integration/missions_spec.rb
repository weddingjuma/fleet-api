require 'swagger_helper'

describe 'Missions API', type: :request do

  before(:all) do
    @company = create(:company, name: 'mapo-company')
    @user = create(:user, company: @company, vehicle: false)

    @missions = create_list(:mission, 3, user: @user, company: @company)

    @other_company = create(:company, name: 'other')
    @other_user = create(:user, company: @other_company)
    @other_missions = create_list(:mission, 2, user: @user, company: @other_company)
  end

  path '/missions' do
    get 'Get all missions' do
      tags 'Missions'
      operationId 'getMissions'
      security [apiKey: []]
      produces 'application/json', 'application/xml'

      response '200', 'all missions' do
        let(:Authorization) { "Token token=#{@user.api_key}" }
        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['missions']).not_to be_empty
          expect(json['missions'].size).to eq(3)
        end
      end

      response '401', 'bad token' do
        let(:Authorization) { "Token token='invalid_token'" }
        run_test!
      end
    end
  end
end

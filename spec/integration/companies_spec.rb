require 'swagger_helper'

describe 'Companies API', type: :request do

  before(:all) do
    @admin = create(:admin)

    @company = create(:company, name: 'mapo-company')

    @other_company = create(:company, name: 'other')
    @user = create(:user, company: @company)
  end

  path '/companies' do
    get 'Get all companies' do
      tags 'Companies'
      security [apiKey: []]
      produces 'application/json', 'application/xml'

      response '200', 'all companies' do
        let(:Authorization) { "Token token=#{@admin.api_key}" }
        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['companies']).not_to be_empty
          expect(json['companies'].size).to eq(2)
        end
      end

      response '401', 'bad token' do
        describe 'invalid token' do
          let(:Authorization) { "Token token='invalid_token'" }
          run_test!
        end

        describe 'token from a user' do
          let(:Authorization) { "Token token=#{@user.api_key}" }
          run_test!
        end
      end
    end
  end
end

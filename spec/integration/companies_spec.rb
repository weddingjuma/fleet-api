require 'swagger_helper'

describe 'Companies API', type: :request do

  before(:all) do
    @admin = create(:admin)

    @company = create(:company, name: 'mapo-company')

    @other_company = create(:company, name: 'other')
    @other_user = create(:user, company: @other_company)
  end

  path '/companies' do
    get 'Get all companies' do
      tags 'Companies'
      operationId 'getCompanies'
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
          let(:Authorization) { "Token token=#{@other_user.api_key}" }
          run_test!
        end
      end
    end

    post 'Creates a company' do
      tags 'Companies'
      operationId 'createCompanies'
      security [apiKey: []]
      consumes 'application/json', 'application/xml'
      parameter name: :company, in: :body, schema: {
        '$ref': '#/definitions/company'
      }

      response '200', 'user created' do
        let(:Authorization) { "Token token=#{@admin.api_key}" }
        let(:company) {  { name: 'company_name' } }
        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['company']['name']).to eq('company_name')
          expect(json['company']['default_mission_status_type_id']).not_to be_empty
        end
      end

      response '422', 'invalid request' do
        let(:Authorization) { "Token token=#{@admin.api_key}" }
        let(:company) { { name: nil } }
        run_test!
      end

      response '401', 'bad token' do
        let(:Authorization) { "Token token=#{@other_user.api_key}" }
        let(:company) { { name: 'company_name' } }
        run_test!
      end
    end
  end
end

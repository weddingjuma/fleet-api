require 'swagger_helper'

describe 'Companies API', type: :request do

  before(:all) do
    @company = create(:company, name: 'mapo-company')
    @user = create(:user, company: @company)
  end

  path '/companies/{company_id}' do
    get 'Get the user company' do
      tags 'Companies'
      operationId 'getCompanies'
      description 'Return the current logged user company\'s'
      security [apiKey: []]
      produces 'application/json', 'application/xml'
      parameter name: :company_id, in: :path, type: :string

      response '200', 'company' do
        let(:Authorization) { "Token token=#{@user.api_key}" }
        let(:company_id) { @company.id }
        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['company']).not_to be_empty
          expect(json['company']['id']).to eq(@company.id)
        end
      end

      response '401', 'bad token' do
        describe 'invalid token' do
          let(:Authorization) { "Token token='invalid_token'" }
          let(:company_id) { @company.id }
          run_test!
        end
      end
    end
  end
end

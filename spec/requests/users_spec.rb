describe 'Users API', type: :request do

  before(:all) do
    @company = create(:company,
                      id: 'company_with_users',
                      name: 'mapo-user')

    @user = User.create(
      company: @company,
      user: 'mapotempo-user',
      email: 'test@mapotempo.com',
      password: 'password'
    )

    @users = create_list(:user, 5, company: @company)
  end

  describe '/v1/users' do
    it 'returns all users' do
      get '/v1/users', headers: token_header(@user.api_key)

      expect(response).to be_json_response

      json = JSON.parse(response.body)
      expect(json['users']).not_to be_empty
      expect(json['users'].size).to eq(6)
    end
  end

  describe '/v1/users/:user_id' do
    context 'without token' do
      it 'returns an error' do
        get "/v1/users/#{@user.user}", headers: @json_header

        expect(response).to be_json_response(401)

        json = JSON.parse(response.body)
        expect(json['errors']).to eq(I18n.t('authentication.bad_credentials'))
      end
    end

    context 'with bad token' do
      it 'returns an error' do
        get "/v1/users/#{@user.user}", headers: token_header('bad_api_key')

        expect(response).to be_json_response(401)

        json = JSON.parse(response.body)
        expect(json['errors']).to eq(I18n.t('authentication.bad_credentials'))
      end
    end

    context 'with correct token' do
      it 'return the user' do
        get "/v1/users/#{@user.user}", headers: token_header(@user.api_key)

        expect(response).to be_json_response(200)

        json = JSON.parse(response.body)
        expect(json['user']).not_to be_empty
        expect(json['user']['user']).to eq(@user.user)
      end
    end
  end
end

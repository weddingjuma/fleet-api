describe 'Missions API', type: :request do

  before(:all) do
    @company = create(:company,
                      name: 'mapo-mission')

    @user = create(:user, company: @company)

    @missions = create_list(:mission, 5, company: @company)
  end

  describe '/v1/missions' do
    it 'returns all missions' do
      get '/v1/missions', headers: token_header(@user.api_key)

      expect(response).to be_json_response

      json = JSON.parse(response.body)
      expect(json['missions']).not_to be_empty
      expect(json['missions'].size).to eq(5)
    end
  end

  describe '/v1/missions (CREATE)' do
    it 'returns all missions' do
      post '/v1/missions', params: {}, headers: token_header(@user.api_key)

      expect(response).to be_json_response

      json = JSON.parse(response.body)
    end
  end

  describe '/v1/missions/:mission_id (DELETE)' do
    it 'returns all missions' do
      delete "/v1/missions/#{@missions.last.id}", params: {}, headers: token_header(@user.api_key)

      expect(response).to be_json_response

      json = JSON.parse(response.body)
    end
  end
end

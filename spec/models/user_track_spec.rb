require 'rails_helper'

RSpec.describe UserTrack, type: :model do

  before(:all) do
    @company = create(:company,
                      name: 'mapo-company')
    @user = create(:user,
                   company: @company,
                   name: 'mapo-user')

    @date = 2.days.ago.strftime('%FT%T.%L%:z')
    @track = UserTrack.create(
      company: @company,
      user: @user,
      date: @date,
      location_details: [{
        lat: -0.56,
        lon: 44.85,
        date: @date,
        accuracy: 3,
        speed: 351,
        bearing: 60,
        elevation: 4000,
        signalStrength: 100,
        cid: 2,
        lac: 5,
        mcc: 456,
        mnc: 789
      }]
    )

    @tracks = create_list(:user_track, 5, company: @company, user: @user)
  end

  subject { @track }

  context 'Object' do
    it { is_expected.to be_valid }

    it { expect(@track.date).to eq(@date) }
    it { expect(@track.location_details.first['lat']).to eq(-0.56) }
    it { expect(@track.location_details.first['lon']).to eq(44.85) }
    it { expect(@track.location_details.first['date']).to eq(@date) }

    it 'set sync_user value automatically' do
      expect(@track.sync_user).to eq(@user.sync_user)
    end

    it 'serializes model' do
      serialized = ActiveModelSerializers::SerializableResource.new(@track, serializer: UserTrackSerializer).as_json
      expect(serialized[:user_track][:id]).to eq(@track.id)
    end
  end

  context 'Views' do
    it 'returns all current locations' do
      expect(UserTrack.all.to_a.size).to eq(6)
    end

    it 'returns all Tracks having the company id' do
      expect(UserTrack.by_company(key: @company.id).to_a.size).to eq(6)
    end

    it 'returns all Tracks having the user' do
      expect(UserTrack.by_user(key: @user.id).to_a.size).to eq(6)
    end
  end

  context 'Relationships' do
    it 'returns the parent company' do
      expect(@track.company.name).to eq(@company.name)
      expect(@track.company).to eq(@company)
    end

    it 'returns the parent user' do
      expect(@track.user.sync_user).to eq(@user.sync_user)
      expect(@track.user).to eq(@user)
    end

    it 'cannot update company id' do
      @track.update(company_id: 'other_company_id')
      expect(@track.errors.first[0]).to eq(:company_id)
      expect(@track.errors.first[1]).to eq(I18n.t('couchbase.errors.models.user_track.company_id_immutable'))
      @track.update(company_id: @company.id)
    end
  end
end

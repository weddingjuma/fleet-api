require 'rails_helper'

RSpec.describe UserCurrentLocation, type: :model do

  before(:all) do
    @company = create(:company,
                      name: 'mapo-company')
    @user = create(:user,
                   company: @company,
                   sync_user: 'mapo-user')

    @date = 2.days.ago.strftime('%FT%T.%L%:z')
    @current_location = UserCurrentLocation.create(
      company: @company,
      user: @user,
      date: @date,
      location_detail: {
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
      }
    )

    @current_locations = create_list(:user_current_location, 5, company: @company, user: @user)
  end

  subject { @current_location }

  context 'Object' do
    it { is_expected.to be_valid }

    it { expect(@current_location.date).to eq(@date) }
    it { expect(@current_location.location_detail['lat']).to eq(-0.56) }
    it { expect(@current_location.location_detail['lon']).to eq(44.85) }
    it { expect(@current_location.location_detail['date']).to eq(@date) }

    it 'set sync_user value automatically' do
      expect(@current_location.sync_user).to eq(@user.sync_user)
    end

    it 'serializes model' do
      serialized = ActiveModelSerializers::SerializableResource.new(@current_location, serializer: UserCurrentLocationSerializer).as_json
      expect(serialized[:user_current_location][:id]).to eq(@current_location.id)
    end
  end

  context 'Views' do
    it 'returns all current locations' do
      expect(UserCurrentLocation.all.to_a.size).to eq(7)
    end

    it 'returns all UserCurrentLocations having the company id' do
      expect(UserCurrentLocation.by_company(key: @company.id).to_a.size).to eq(7)
    end

    it 'returns all UserCurrentLocations having the user' do
      expect(UserCurrentLocation.by_user(key: @user.id).to_a.size).to eq(7)
    end

    it 'returns user settings by sync_user or id' do
      expect(UserCurrentLocation.find_by(@user.id).id).to eq(@user.current_location.id)
    end

    it 'returns the first user settings' do
      expect(UserCurrentLocation.first).to be_a(UserCurrentLocation)
    end

    it 'returns the last user settings' do
      expect(UserCurrentLocation.last).to be_a(UserCurrentLocation)
    end
  end

  context 'Relationships' do
    it 'returns the parent company' do
      expect(@current_location.company.name).to eq(@company.name)
      expect(@current_location.company).to eq(@company)
    end

    it 'returns the parent user' do
      expect(@current_location.user.sync_user).to eq(@user.sync_user)
      expect(@current_location.user).to eq(@user)
    end

    it 'cannot update company id' do
      @current_location.update(company_id: 'other_company_id')
      expect(@current_location.errors.first[0]).to eq(:company_id)
      expect(@current_location.errors.first[1]).to eq(I18n.t('couchbase.errors.models.user_current_location.company_id_immutable'))
      @current_location.update(company_id: @company.id)
    end
  end
end

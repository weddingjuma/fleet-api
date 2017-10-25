require 'rails_helper'

RSpec.describe CurrentLocation, type: :model do

  before(:all) do
    @company = create(:company,
                      name: 'mapo-company')
    @user = create(:user,
                   company: @company,
                   sync_user: 'mapo-user')

    @date = 2.days.ago.strftime('%FT%T.%L%:z')
    @current_location = CurrentLocation.create(
      company: @company,
      user: @user,
      date: @date,
      locationDetail: {
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

    @current_locations = create_list(:current_location, 5, company: @company, user: @user)
  end

  subject { @current_location }

  context 'Object' do
    it { is_expected.to be_valid }

    it { expect(@current_location.date).to eq(@date) }
    it { expect(@current_location.locationDetail['lat']).to eq(-0.56) }
    it { expect(@current_location.locationDetail['lon']).to eq(44.85) }
    it { expect(@current_location.locationDetail['date']).to eq(@date) }

    it 'set sync_user value automatically' do
      expect(@current_location.sync_user).to eq(@user.sync_user)
    end

    it 'serializes model' do
      serialized = ActiveModelSerializers::SerializableResource.new(@current_location, serializer: CurrentLocationSerializer).as_json
      expect(serialized[:current_location][:id]).to eq(@current_location.id)
    end
  end

  context 'Views' do
    it 'returns all current locations' do
      expect(CurrentLocation.all.to_a.size).to eq(7)
    end

    it 'returns all CurrentLocations having the company id' do
      expect(CurrentLocation.by_company(key: @company.id).to_a.size).to eq(7)
    end

    it 'returns all CurrentLocations having the user' do
      expect(CurrentLocation.by_user(key: @user.id).to_a.size).to eq(7)
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
      expect(@current_location.errors.first[1]).to eq(I18n.t('couchbase.errors.models.current_location.company_id_immutable'))
      @current_location.update(company_id: @company.id)
    end
  end
end

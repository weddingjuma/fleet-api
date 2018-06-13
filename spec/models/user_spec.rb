require 'rails_helper'

RSpec.describe User, type: :model do

  before(:all) do
    @company = create(:company,
                      id: 'company_with_users',
                      name: 'mapo-user')

    @user = User.create(
      company: @company,
      name: 'mapotempo-user',
      email: 'test@mapotempo.com',
      phone: '0000000001'
      password: 'password'
    )

    @user_without_vehicle = User.create(
      company: @company,
      name: 'admin-user',
      email: 'admin@mapotempo.com',
      vehicle: false
    )

    @users = create_list(:user, 5, company: @company, vehicle: true)
  end

  subject { @user }

  context 'Object' do
    it { is_expected.to be_valid }

    it { expect(@user.name).to eq('mapotempo-user') }

    it 'validates password only if user is not a vehicle' do
      expect(@user_without_vehicle).to be_valid
      expect(@user_without_vehicle.password_hash).to be nil

      expect(@user.password_hash).not_to be nil
    end

    it 'generates sync user on creation' do
      expect(@user.sync_user).to be_a(String)
      expect(@user.sync_user).not_to be_empty
      expect(@user_without_vehicle.sync_user).to be_a(String)
      expect(@user_without_vehicle.sync_user).not_to be_empty
    end

    it 'generates api key on creation' do
      expect(@user.api_key).to be_a(String)
      expect(@user.api_key).not_to be_empty
      expect(@user_without_vehicle.api_key).to be_a(String)
      expect(@user_without_vehicle.api_key).not_to be_empty
    end

    it 'ensures vehicle value' do
      expect(@user.vehicle).to be true
      expect(@user_without_vehicle.vehicle).to be false
    end

    it 'serializes model' do
      serialized = ActiveModelSerializers::SerializableResource.new(@user, serializer: UserSerializer).as_json
      expect(serialized[:user][:id]).to eq(@user.id)
    end

    it 'returns user by sync_user or id' do
      expect(User.find_by(@user.sync_user).id).to eq(@user.id)
      expect(User.find_by(@user.id).id).to eq(@user.id)
    end

    it 'returns the first user' do
      expect(User.first).to be_a(User)
    end

    it 'returns the last user' do
      expect(User.last).to be_a(User)
    end
  end

  context 'Views' do
    it 'returns all users' do
      expect(User.all.to_a.size).to eq(7)
    end

    it 'returns a user by its name' do
      expect(User.by_name(key: 'mapotempo-user').to_a.size).to eq(1)
    end

    it 'returns a user by its sync user' do
      expect(User.by_sync_user(key: @user.sync_user).to_a.size).to eq(1)
    end

    it 'returns all users having the company id' do
      expect(User.by_company(key: 'company_with_users').to_a.size).to eq(7)
    end

    it 'returns a user by its token' do
      expect(User.by_token(key: @user.api_key).to_a.size).to eq(1)
    end
  end

  context 'Relationships' do
    it 'returns the parent company' do
      expect(@user.company).to eq(@company)
      expect(@user.company.name).to eq('mapo-user')
    end

    it 'creates settings along with user' do
      expect(@user.settings).to be_a(UserSettings)
      expect(@user.settings.data_connection).to be true
    end

    it 'returns its current location if user is a vehicle' do
      expect(@user_without_vehicle.current_location).to be nil

      expect(@user.current_location).not_to be nil
      expect(@user.current_location.location_detail['lat']).to be nil
    end

    it 'cannot update company id' do
      @user.update(company_id: 'other_company_id')

      expect(@user.errors.first[0]).to eq(:company_id)
      expect(@user.errors.first[1]).to eq(I18n.t('couchbase.errors.models.user.company_id_immutable'))
    end
  end
end

require 'rails_helper'

RSpec.describe User, type: :model do

  before(:all) do
    @company = create(:company,
                      id: 'company_with_users',
                      name: 'mapo-user')

    @user = User.create(
      company: @company,
      sync_user: 'mapotempo-user',
      email: 'test@mapotempo.com',
      password: 'password',
      vehicle: false
    )

    @users = create_list(:user, 5, company: @company, vehicle: true)
  end

  subject { @user }

  context 'Object' do
    it { is_expected.to be_valid }

    it { expect(@user.sync_user).to eq('mapotempo-user') }

    it 'generate api key on creation' do
      expect(@user.api_key).not_to be_nil
    end

    it 'ensure vehicle value' do
      expect(@user.vehicle).to be false
      expect(@users.first.vehicle).to be true
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
  end

  context 'Views' do
    it 'returns all users' do
      expect(User.all.to_a.size).to eq(6)
    end

    it 'returns a user by its name' do
      expect(User.by_sync_user(key: 'mapotempo-user').to_a.size).to eq(1)
    end

    it 'returns all users having the company id' do
      expect(User.by_company(key: 'company_with_users').to_a.size).to eq(6)
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

    it 'returns its current location if user is a vehicle' do
      expect(@user.current_location).to be nil

      expect(@users.first.current_location).not_to be nil
      expect(@users.first.current_location.location_detail['lat']).to be nil
    end

    it 'cannot update company id' do
      @user.update(company_id: 'other_company_id')

      expect(@user.errors.first[0]).to eq(:company_id)
      expect(@user.errors.first[1]).to eq(I18n.t('couchbase.errors.models.user.company_id_immutable'))
    end
  end
end

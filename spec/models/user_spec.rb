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
      password: 'password'
    )

    @users = create_list(:user, 5, company: @company)
  end

  subject { @user }

  context 'Object' do
    it { is_expected.to be_valid }

    it { expect(@user.sync_user).to eq('mapotempo-user') }
    # it { is_expected.to validate_presence_of(:sync_user) }

    # it { is_expected.to validate_presence_of(:email) }

    it 'generate api key on creation' do
      expect(@user.api_key).not_to be_nil
    end

    it 'serializes model' do
      serialized = ActiveModelSerializers::SerializableResource.new(@user, serializer: UserSerializer).as_json
      expect(serialized[:user][:id]).to eq(@user.id)
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

    it 'cannot update company id' do
      @user.update(company_id: 'other_company_id')

      expect(@user.errors.first[0]).to eq(:company_id)
      expect(@user.errors.first[1]).to eq(I18n.t('couchbase.errors.models.user.company_id_immutable'))
    end
  end
end

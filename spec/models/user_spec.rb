require 'rails_helper'

RSpec.describe User, type: :model do

  before(:all) do
    Company.ensure_design_document!
    User.ensure_design_document!
    Mission.ensure_design_document!

    @company = create(:company,
                      id: 'company_with_users',
                      name: 'mapo-user')

    @user = User.create(
      company: @company,
      user: 'mapotempo-user'
    )

    @users = create_list(:user, 5, company: @company)
  end

  subject { @user }

  context 'Object' do
    it { is_expected.to be_valid }

    it { expect(@user.user).to eq('mapotempo-user') }
    it { expect(@user.company.name).to eq('mapo-user') }
    it { is_expected.to validate_presence_of(:user) }
  end

  context 'Views' do
    it 'returns all users' do
      expect(User.all.to_a.size).to eq(6)
    end

    it 'returns a user by its name' do
      expect(User.by_user(key: 'mapotempo-user').to_a.size).to eq(1)
    end

    it 'returns all users having ths company id' do
      expect(User.by_company(key: 'company_with_users').to_a.size).to eq(6)
    end
  end

  context 'Relationships' do
    it 'returns the parent company' do
      expect(@user.company).to eq(@company)
    end
  end
end

require 'rails_helper'

RSpec.describe Admin, type: :model do

  before(:all) do
    @admin = Admin.create(
      name: 'admin',
      email: 'admin@mapotempo.com',
      password: 'password'
    )

    @admins = create_list(:admin, 5)
  end

  subject { @admin }

  context 'Object' do
    it { is_expected.to be_valid }

    it { expect(@admin.name).to eq('admin') }

    it 'generate api key on creation' do
      expect(@admin.api_key).not_to be_nil
    end
  end

  context 'Views' do
    it 'returns all admins' do
      expect(Admin.all.to_a.size).to eq(6)
    end

    it 'returns a admin by its name' do
      expect(Admin.by_name(key: 'admin').to_a.size).to eq(1)
    end

    it 'returns a admin by its token' do
      expect(Admin.by_token(key: @admin.api_key).to_a.size).to eq(1)
    end
  end
end

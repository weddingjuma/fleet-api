require 'rails_helper'

RSpec.describe Company, type: :model do

  before(:all) do
    Company.ensure_design_document!
    User.ensure_design_document!
    Mission.ensure_design_document!

    @company = Company.create(
      id: 'company_id',
      name: 'mapotempo'
    )

    @companies = create_list(:company, 5)

    @users = create_list(:user, 3, company: @company)
    @missions = create_list(:mission, 3, company: @company)
  end

  subject { @company }

  context 'Object' do
    it { is_expected.to be_valid }

    it { expect(@company.name).to eq('mapotempo') }
    it { is_expected.to validate_presence_of(:name) }
  end

  context 'Views' do
    it 'returns all companies' do
      expect(Company.all.to_a.size).to eq(6)
    end

    it 'returns a company by its name' do
      expect(Company.by_name(key: 'mapotempo').to_a.size).to eq(1)
    end
  end

  context 'Relationships' do
    it 'returns all users for a company' do
      company_with_users = Company.find('company_id')
      expect(company_with_users.users.to_a.size).to eq(3)
    end

    it 'returns all missions for a company' do
      company_with_missions = Company.find('company_id')
      expect(company_with_missions.missions.to_a.size).to eq(3)
    end
  end
end

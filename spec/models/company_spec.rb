require 'rails_helper'

RSpec.describe Company, type: :model do

  before(:all) do
    @company = Company.create(
      id: 'company_id',
      name: 'mapotempo',
      default_mission_status_type_id: 'type_id'
    )

    @companies = create_list(:company, 5)

    @users = create_list(:user, 3, company: @company)
    @missions = create_list(:mission, 3, company: @company, user: @users.first)
  end

  subject { @company }

  context 'Object' do
    it { is_expected.to be_valid }

    it { expect(@company.name).to eq('mapotempo') }

    it 'serializes model' do
      serialized = ActiveModelSerializers::SerializableResource.new(@company, serializer: CompanySerializer).as_json
      expect(serialized[:company][:id]).to eq(@company.id)
    end

    it 'cannot have another company with the same name' do
      same_company_name = build(:company, name: @company.name)
      expect(same_company_name.save).to be false
    end

    it 'creates a default workflow' do
      @company.set_workflow

      expect(@company.mission_status_types.to_a.count).to eq(4)
    end

    it 'creates an admin user associated to the company' do
      user = @company.create_admin_user('admin@mapotempo.com')

      expect(user.email).to eq('admin@mapotempo.com')
      expect(User.last.company_id).to eq(@company.id)
    end
  end

  context 'Views' do
    it 'returns all companies' do
      expect(Company.all.to_a.size).to eq(6)
    end

    it 'returns a company by its name' do
      expect(Company.by_name(key: 'mapotempo').to_a.size).to eq(1)
    end

    it 'returns the first company' do
      expect(Company.first).to be_a(Company)
    end

    it 'returns the last company' do
      expect(Company.last).to be_a(Company)
    end
  end

  context 'Relationships' do
    it 'returns all users for a company' do
      company_with_users = Company.find('company_id')
      expect(company_with_users.users.to_a.size).to eq(4)
    end

    it 'returns all missions for a company' do
      company_with_missions = Company.find('company_id')
      expect(company_with_missions.missions.to_a.size).to eq(3)
    end
  end
end

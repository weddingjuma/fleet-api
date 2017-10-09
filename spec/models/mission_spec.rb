require 'rails_helper'

RSpec.describe Mission, type: :model do

  before(:all) do
    Company.ensure_design_document!
    User.ensure_design_document!
    Mission.ensure_design_document!

    @company = create(:company,
                      id: 'company_with_missions',
                      name: 'mapo-mission')

    @mission = Mission.create(
      company: @company,
      name: 'mission name'
    )

    @missions = create_list(:mission, 5, company: @company)
  end

  subject { @mission }

  context 'Object' do
    it { is_expected.to be_valid }

    it { expect(@mission.name).to eq('mission name') }
    it { expect(@mission.company.name).to eq('mapo-mission') }
  end

  context 'Views' do
    it 'returns all missions' do
      expect(Mission.all.to_a.size).to eq(6)
    end

    it 'returns all missions having ths company id' do
      expect(Mission.by_company(key: 'company_with_missions').to_a.size).to eq(6)
    end
  end

  context 'Relationships' do
    it 'returns the parent company' do
      expect(@mission.company).to eq(@company)
    end
  end
end

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
      name: 'mission name',
      location: {
        lat: -0.5680988,
        lon: 44.8547927
      }
    )

    @missions = create_list(:mission, 5, company: @company)
  end

  subject { @mission }

  context 'Object' do
    it { is_expected.to be_valid }

    it { expect(@mission.name).to eq('mission name') }
    it { expect(@mission.company.name).to eq('mapo-mission') }
    it { expect(@mission.location['lat']).to eq(-0.5680988) }
    it { expect(@mission.location['lon']).to eq(44.8547927) }
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

    it 'cannot update company id' do
      @mission.update(company_id: 'other_company_id')
      expect(@mission.errors.first[0]).to eq(:company_id)
      expect(@mission.errors.first[1]).to eq(I18n.t('couchbase.errors.models.user.company_id_immutable'))
    end
  end
end

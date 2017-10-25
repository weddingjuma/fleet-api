require 'rails_helper'

RSpec.describe Mission, type: :model do

  before(:all) do
    @company = create(:company,
                      id: 'company_with_missions',
                      name: 'mapo-company')
    @user = create(:user,
                   company: @company,
                   sync_user: 'mapo-user')

    @todo_status_type = create(:mission_status_type, company: @company, label: 'To do', color: '#ff0000')
    @company.update_attribute(:default_mission_status_type_id, @todo_status_type.id)

    @date = 2.days.ago.strftime('%FT%T.%L%:z')
    @mission = Mission.create(
      company: @company,
      external_ref: 'uniq_ref_by_company',
      user: @user,
      name: 'mission name',
      date: @date,
      location: {
        lat: -0.5680988,
        lon: 44.8547927
      }
    )

    @missions = create_list(:mission, 5, company: @company, user: @user)
  end

  subject { @mission }

  context 'Object' do
    it { is_expected.to be_valid }

    it { expect(@mission.name).to eq('mission name') }
    it { expect(@mission.date).to eq(@date) }
    it { expect(@mission.location['lat']).to eq(-0.5680988) }
    it { expect(@mission.location['lon']).to eq(44.8547927) }

    it 'set sync_user value automatically' do
      expect(@mission.sync_user).to eq(@user.sync_user)
    end

    it 'set a default status type from the company' do
      expect(@mission.mission_status_type_id).to eq(@todo_status_type.id)
    end

    it 'serializes model' do
      serialized = ActiveModelSerializers::SerializableResource.new(@mission, serializer: MissionSerializer).as_json
      expect(serialized[:mission][:id]).to eq(@mission.id)
    end

    it 'cannot update external ref' do
      @mission.update(external_ref: 'other_external_ref')
      expect(@mission.errors.first[0]).to eq(:external_ref)
      expect(@mission.errors.first[1]).to eq(I18n.t('couchbase.errors.models.mission.external_ref_immutable'))
      @mission.update(external_ref: 'uniq_ref_by_company')
    end

    it 'cannot have another mission with the same external ref for the same company' do
      same_external_ref = build(:mission, company: @company, user: @user, external_ref: @mission.external_ref)
      expect(same_external_ref.save).to be false
    end

    it 'returns mission by external_ref or id' do
      expect(Mission.find_by(@mission.external_ref, @company.id).id).to eq(@mission.id)
      expect(Mission.find_by(@mission.id).id).to eq(@mission.id)
    end
  end

  context 'Views' do
    it 'returns all missions' do
      expect(Mission.all.to_a.size).to eq(6)
    end

    it 'returns all missions having the company id' do
      expect(Mission.by_company(key: 'company_with_missions').to_a.size).to eq(6)
    end

    it 'returns all missions having the user' do
      expect(Mission.by_user(key: @user.id).to_a.size).to eq(6)
    end
  end

  context 'Relationships' do
    it 'returns the parent company' do
      expect(@mission.company.name).to eq(@company.name)
      expect(@mission.company).to eq(@company)
    end

    it 'returns the parent user' do
      expect(@mission.user.sync_user).to eq(@user.sync_user)
      expect(@mission.user).to eq(@user)
    end

    it 'has an optional mission status type' do
      mission_status_type = create(:mission_status_type, company: @company)
      @mission.mission_status_type = mission_status_type
      @mission.save
      expect(@mission.mission_status_type).to eq(mission_status_type)
    end

    it 'cannot update company id' do
      @mission.update(company_id: 'other_company_id')
      expect(@mission.errors.first[0]).to eq(:company_id)
      expect(@mission.errors.first[1]).to eq(I18n.t('couchbase.errors.models.current_location.company_id_immutable'))
      @mission.update(company_id: @company.id)
    end
  end
end

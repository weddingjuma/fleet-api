require 'rails_helper'

RSpec.describe MissionStatusType, type: :model do

  before(:all) do
    @company = create(:company,
                      name: 'mapo-user')

    @mission_status_type = MissionStatusType.create(
      company: @company,
      reference: 'completed',
      label: 'Completed',
      color: '#228b22'
    )

    @mission_status_types = create_list(:mission_status_type, 5, company: @company)
  end

  subject { @mission_status_type }

  context 'Object' do
    it { is_expected.to be_valid }

    it { expect(@mission_status_type.label).to eq('Completed') }

    it 'serializes model' do
      serialized = ActiveModelSerializers::SerializableResource.new(@mission_status_type, serializer: MissionStatusTypeSerializer).as_json
      expect(serialized[:mission_status_type][:id]).to eq(@mission_status_type.id)
    end
  end

  context 'Views' do
    it 'returns all mission status type' do
      expect(MissionStatusType.all.to_a.size).to eq(6)
    end

    it 'returns all users having the company id' do
      expect(MissionStatusType.by_company(key: @company.id).to_a.size).to eq(6)
    end
  end

  context 'Relationships' do
    it 'returns the parent company' do
      expect(@mission_status_type.company).to eq(@company)
      expect(@mission_status_type.company.name).to eq('mapo-user')
    end

    describe 'mission status actions' do
      before(:all) do
        @related_status_type = create(:mission_status_type, company: @company)

        @action = create(:mission_status_action,
                         company: @company,
                         previous_mission_status_type: @mission_status_type,
                         next_mission_status_type: @related_status_type)
      end

      it 'returns related types through action' do
        expect(@mission_status_type.related_missions.to_a.size).to eq(1)
        expect(@mission_status_type.related_missions.to_a.first).to eq(@related_status_type)
      end
    end
  end
end

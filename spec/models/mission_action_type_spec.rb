require 'rails_helper'

RSpec.describe MissionActionType, type: :model do

  before(:all) do
    @company = create(:company,
                      name: 'mapo-user')

    @previous_mission_status_type = create(:mission_status_type, company: @company)
    @next_mission_status_type = create(:mission_status_type, company: @company)

    @mission_action_type = MissionActionType.create(
      company: @company,
      previous_mission_status_type: @previous_mission_status_type,
      next_mission_status_type: @next_mission_status_type,
      label: 'To pending',
      group: 'default'
    )
  end

  subject { @mission_action_type }

  context 'Object' do
    it { is_expected.to be_valid }

    it { expect(@mission_action_type.label).to eq('To pending') }

    it 'serializes model' do
      serialized = ActiveModelSerializers::SerializableResource.new(@mission_action_type, serializer: MissionActionTypeSerializer).as_json
      expect(serialized[:mission_action_type][:id]).to eq(@mission_action_type.id)
    end
  end

  context 'Views' do
    it 'returns all mission action types' do
      expect(MissionActionType.all.to_a.size).to eq(1)
    end

    it 'returns all mission action types having the company id' do
      expect(MissionActionType.by_company(key: @company.id).to_a.size).to eq(1)
    end
  end

  context 'Relationships' do
    it 'returns the parent company' do
      expect(@mission_action_type.company).to eq(@company)
      expect(@mission_action_type.company.name).to eq('mapo-user')
    end

    it 'returns the related missions action types' do
      expect(@mission_action_type.previous_mission_status_type).to eq(@previous_mission_status_type)
      expect(@mission_action_type.next_mission_status_type).to eq(@next_mission_status_type)
    end
  end
end

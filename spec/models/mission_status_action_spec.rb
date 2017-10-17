require 'rails_helper'

RSpec.describe MissionStatusAction, type: :model do

  before(:all) do
    @company = create(:company,
                      name: 'mapo-user')

    @previous_mission_status_type = create(:mission_status_type, company: @company)
    @next_mission_status_type = create(:mission_status_type, company: @company)

    @mission_status_action = MissionStatusAction.create(
      company: @company,
      previous_mission_status_type: @previous_mission_status_type,
      next_mission_status_type: @next_mission_status_type,
      label: 'To pending',
      group: 'default'
    )
  end

  subject { @mission_status_action }

  context 'Object' do
    it { is_expected.to be_valid }

    it { expect(@mission_status_action.label).to eq('To pending') }

    it 'serializes model' do
      serialized = ActiveModelSerializers::SerializableResource.new(@mission_status_action, serializer: MissionStatusActionSerializer).as_json
      expect(serialized[:mission_status_action][:id]).to eq(@mission_status_action.id)
    end
  end

  context 'Views' do
    it 'returns all mission status type' do
      expect(MissionStatusType.all.to_a.size).to eq(2)
    end

    it 'returns all users having the company id' do
      expect(MissionStatusType.by_company(key: @company.id).to_a.size).to eq(2)
    end
  end

  context 'Relationships' do
    it 'returns the parent company' do
      expect(@mission_status_action.company).to eq(@company)
      expect(@mission_status_action.company.name).to eq('mapo-user')
    end

    it 'returns the related missions status types' do
      expect(@mission_status_action.previous_mission_status_type).to eq(@previous_mission_status_type)
      expect(@mission_status_action.next_mission_status_type).to eq(@next_mission_status_type)
    end
  end
end

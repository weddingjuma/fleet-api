require 'rails_helper'

RSpec.describe MissionEventType, type: :model do

  before(:all) do
    @company = create(:company,
                      name: 'mapo-user')

    @mission_action_type = create(
      :mission_action_type,
      company: @company,
      previous_mission_status_type: create(:mission_status_type, company: @company),
      next_mission_status_type: create(:mission_status_type, company: @company),
      label: 'To pending',
      group: 'default'
    )

    @mission_event_type = MissionEventType.create(
      company: @company,
      mission_action_type: @mission_action_type,
      group: 'default',
      context: 'server'
    )
  end

  subject { @mission_event_type }

  context 'Object' do
    it { is_expected.to be_valid }

    it { expect(@mission_event_type.context).to eq('server') }

    # it 'serializes model' do
    #   serialized = ActiveModelSerializers::SerializableResource.new(@mission_event_type, serializer: MissionEventTypeSerializer).as_json
    #   expect(serialized[:mission_event_type][:id]).to eq(@mission_event_type.id)
    # end
  end

  context 'Views' do
    it 'returns all mission event types' do
      expect(MissionEventType.all.to_a.size).to eq(1)
    end

    it 'returns all mission event types having the company id' do
      expect(MissionEventType.by_company(key: @company.id).to_a.size).to eq(1)
    end
  end

  context 'Relationships' do
    it 'returns the parent company' do
      expect(@mission_event_type.company).to eq(@company)
      expect(@mission_event_type.company.name).to eq('mapo-user')
    end

    it 'returns the related missions action types' do
      expect(@mission_event_type.mission_action_type).to eq(@mission_action_type)
    end
  end
end

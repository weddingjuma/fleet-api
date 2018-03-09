require 'rails_helper'

RSpec.describe MissionAction, type: :model do

  before(:all) do
    @company = create(:company,
                      name: 'mapo-user')
    @user = create(:user,
                   company: @company,
                   name: 'mapo-user')
    @mission = create(:mission,
                      company: @company,
                      user: @user)
    @date = 2.days.ago.strftime('%FT%T.%L%:z')

    @mission_action_type = MissionActionType.create(
      company: @company,
      previous_mission_status_type: create(:mission_status_type, company: @company, label: 'To do', color: '#337AB7', svg_path: ''),
      next_mission_status_type:  create(:mission_status_type, company: @company, label: 'In progress', color: '#F0AD4E', svg_path: ''),
      label: 'To pending'
    )

    @mission_action = MissionAction.create(
      company: @company,
      mission_id: @mission,
      mission_action_type: @mission_action_type,
      date: @date
    )

    @mission_actions = create_list(:mission_action, 5, company: @company,
                                    mission_id: @mission,
                                    mission_action_type: @mission_action_type)
  end

  subject { @mission_action }

  context 'Object' do
    it { is_expected.to be_valid }

    it { expect(@mission_action.date).to eq(@date) }

    it 'serializes model' do
      serialized = ActiveModelSerializers::SerializableResource.new(@mission_action, serializer: MissionActionSerializer).as_json
      expect(serialized[:mission_action][:id]).to eq(@mission_action.id)
    end
  end

  context 'Views' do
    it 'returns all mission status type' do
      expect(MissionAction.all.to_a.size).to eq(6)
    end

    it 'returns all users having the company id' do
      expect(MissionAction.by_company(key: @company.id).to_a.size).to eq(6)
    end
  end

  context 'Relationships' do
    it 'returns the parent company' do
      expect(@mission_action.company).to eq(@company)
      expect(@mission_action.company.name).to eq('mapo-user')
    end

    it 'cannot update company id' do
      @mission_action.update(company_id: 'other_company_id')
      expect(@mission_action.errors.first[0]).to eq(:company_id)
      expect(@mission_action.errors.first[1]).to eq(I18n.t('couchbase.errors.models.missions_placeholder.company_id_immutable'))
      @mission_action.update(company_id: @company.id)
    end
  end
end

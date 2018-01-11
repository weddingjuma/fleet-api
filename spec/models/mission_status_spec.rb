require 'rails_helper'

RSpec.describe MissionStatus, type: :model do

  before(:all) do
    @company = create(:company,
                      name: 'mapo-user')
    @user = create(:user,
                   company: @company,
                   sync_user: 'mapo-user')
    @todo_status_type = create(:mission_status_type,
                               company: @company,
                               label: 'To do',
                               color: '#337AB7',
                               svg_path: '')
    @mission = create(:mission,
                      company: @company,
                      user: @user)
    @date = 2.days.ago.strftime('%FT%T.%L%:z')

    @mission_status = MissionStatus.create(
      company: @company,
      mission_id: @mission,
      mission_status_type: @todo_status_type,
      date: @date,
      description: 'Mission status description'
    )

    @mission_statuses = create_list(:mission_status, 5, company: @company,
                                    mission_id: @mission,
                                    mission_status_type: @todo_status_type)
  end

  subject { @mission_status }

  context 'Object' do
    it { is_expected.to be_valid }

    it { expect(@mission_status.date).to eq(@date) }

    it 'serializes model' do
      serialized = ActiveModelSerializers::SerializableResource.new(@mission_status, serializer: MissionStatusSerializer).as_json
      expect(serialized[:mission_status][:id]).to eq(@mission_status.id)
    end
  end

  context 'Views' do
    it 'returns all mission status type' do
      expect(MissionStatus.all.to_a.size).to eq(6)
    end

    it 'returns all users having the company id' do
      expect(MissionStatus.by_company(key: @company.id).to_a.size).to eq(6)
    end
  end

  context 'Relationships' do
    it 'returns the parent company' do
      expect(@mission_status.company).to eq(@company)
      expect(@mission_status.company.name).to eq('mapo-user')
    end

    it 'cannot update company id' do
      @mission_status.update(company_id: 'other_company_id')
      expect(@mission_status.errors.first[0]).to eq(:company_id)
      expect(@mission_status.errors.first[1]).to eq(I18n.t('couchbase.errors.models.missions_placeholder.company_id_immutable'))
      @mission_status.update(company_id: @company.id)
    end
  end
end

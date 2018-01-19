require 'rails_helper'

RSpec.describe MissionsPlaceholder, type: :model do

  before(:all) do
    @company = create(:company,
                      id: 'company_with_missions_placeholders',
                      name: 'mapo-company')
    @user = create(:user,
                   company: @company,
                   name: 'mapo-user')

    @date = 2.days.ago.strftime('%F')
    @missions_placeholder = MissionsPlaceholder.create(
      company: @company,
      sync_user: @user.sync_user,
      date: @date
    )

    @mission = create(:mission, company: @company, user: @user)
  end

  subject { @missions_placeholder }

  context 'Object' do
    it { is_expected.to be_valid }

    it { expect(@missions_placeholder.date).to eq(@date) }

    it 'serializes model' do
      serialized = ActiveModelSerializers::SerializableResource.new(@missions_placeholder, serializer: MissionsPlaceholderSerializer).as_json
      expect(serialized[:missions_placeholder][:id]).to eq(@missions_placeholder.id)
    end

    it 'checks date format' do
      @missions_placeholder.update(date: 2.days.ago.strftime('%FT%T.%L%:z'))
      expect(@missions_placeholder.errors.first[0]).to eq(:date)
      expect(@missions_placeholder.errors.first[1]).to eq(I18n.t('couchbase.errors.models.missions_placeholder.date_format'))
      @missions_placeholder.update(date: @date)
    end

    it 'cannot update sync_user' do
      @missions_placeholder.update(sync_user: 'other_sync_user')
      expect(@missions_placeholder.errors.first[0]).to eq(:sync_user)
      expect(@missions_placeholder.errors.first[1]).to eq(I18n.t('couchbase.errors.models.missions_placeholder.sync_user_immutable'))
    end

    it 'returns mission placeholder by date or id' do
      expect(MissionsPlaceholder.find_by(@missions_placeholder.id).id).to eq(@missions_placeholder.id)
      expect(MissionsPlaceholder.find_by(@missions_placeholder.date, @user.sync_user, @company.id).id).to eq(@missions_placeholder.id)
    end

    it 'returns mission placeholder by mission' do
      expect(MissionsPlaceholder.find_by_mission(@mission)).not_to be_nil
    end
  end

  context 'Views' do
    it 'returns all missions placeholder' do
      expect(MissionsPlaceholder.all.to_a.size).to eq(2)
    end

    it 'returns all missions placeholder having the company id' do
      expect(MissionsPlaceholder.by_company(key: 'company_with_missions_placeholders').to_a.size).to eq(2)
    end

    it 'returns all missions placeholder having the user' do
      expect(MissionsPlaceholder.by_sync_user(key: [@company.id, @user.sync_user]).to_a.size).to eq(2)
    end
  end

  context 'Relationships' do
    it 'returns the parent company' do
      expect(@missions_placeholder.company.name).to eq(@company.name)
      expect(@missions_placeholder.company).to eq(@company)
    end

    it 'cannot update company id' do
      @missions_placeholder.update(company_id: 'other_company_id')
      expect(@missions_placeholder.errors.first[0]).to eq(:company_id)
      expect(@missions_placeholder.errors.first[1]).to eq(I18n.t('couchbase.errors.models.missions_placeholder.company_id_immutable'))
      @missions_placeholder.update(company_id: @company.id)
    end
  end
end

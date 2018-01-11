require 'rails_helper'

RSpec.describe UserSettings, type: :model do

  before(:all) do
    @company = create(:company,
                      name: 'mapo-company')
    @user = create(:user,
                   company: @company,
                   sync_user: 'mapo-user')

    @user_settings = UserSettings.create(company: @company,
                                         user: @user,
                                         data_connection: true,
                                         automatic_data_update: true,
                                         map_current_position: true,
                                         night_mode: 'automatic'
    )

    create_list(:user_settings, 5, company: @company, user: @user)
  end

  subject { @user_settings }

  context 'Object' do
    it { is_expected.to be_valid }

    it { expect(@user_settings.data_connection).to be true }
    it { expect(@user_settings.automatic_data_update).to be true }
    it { expect(@user_settings.map_current_position).to be true }
    it { expect(@user_settings.night_mode).to eq('automatic') }

    it 'set sync_user value automatically' do
      expect(@user_settings.sync_user).to eq(@user.sync_user)
    end
  end

  context 'Views' do
    it 'returns all current locations' do
      expect(UserSettings.all.to_a.size).to eq(7)
    end

    it 'returns all user settings having the company id' do
      expect(UserSettings.by_company(key: @company.id).to_a.size).to eq(7)
    end

    it 'returns all user settings having the user' do
      expect(UserSettings.by_user(key: @user.id).to_a.size).to eq(7)
    end

    it 'returns user settings by sync_user or id' do
      expect(UserSettings.find_by(@user.id).id).to eq(@user.settings.id)
    end

    it 'returns the first user settings' do
      expect(UserSettings.first).to be_a(UserSettings)
    end

    it 'returns the last user settings' do
      expect(UserSettings.last).to be_a(UserSettings)
    end
  end

  context 'Relationships' do
    it 'returns the parent company' do
      expect(@user_settings.company.name).to eq(@company.name)
      expect(@user_settings.company).to eq(@company)
    end

    it 'returns the parent user' do
      expect(@user_settings.user.sync_user).to eq(@user.sync_user)
      expect(@user_settings.user).to eq(@user)
    end

    it 'cannot update company id' do
      @user_settings.update(company_id: 'other_company_id')
      expect(@user_settings.errors.first[0]).to eq(:company_id)
      expect(@user_settings.errors.first[1]).to eq(I18n.t('couchbase.errors.models.user_current_location.company_id_immutable'))
      @user_settings.update(company_id: @company.id)
    end
  end
end

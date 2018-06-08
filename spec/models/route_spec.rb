require 'rails_helper'

RSpec.describe Route, type: :model do

  before(:all) do
    @company = create(:company,
                      name: 'mapo-company')
    @user = create(:user,
                   company: @company,
                   name: 'mapo-user')

    @route = Route.create(
      company: @company,
      user: @user,
      name: 'mapotempo-route',
      date: Date.today.to_s,
      external_ref: 'abcdef'
    )

    @routes = create_list(:route, 3, company: @company, user: @user)

  end

  subject { @route }

  context 'Object' do
    it { is_expected.to be_valid }

    it { expect(@route.name).to eq('mapotempo-route') }

    it 'set sync_user value automatically' do
      expect(@route.sync_user).to eq(@user.sync_user)
    end

    it 'serializes model' do
      serialized = ActiveModelSerializers::SerializableResource.new(@route, serializer: RouteSerializer).as_json
      expect(serialized[:route][:id]).to eq(@route.id)
    end
  end

  context 'Views' do
    it 'returns all current routes' do
      expect(Route.all.to_a.size).to eq(4)
    end

    it 'returns all Tracks having the company id' do
      expect(Route.by_company(key: @company.id).to_a.size).to eq(4)
    end

    it 'returns all Tracks having the user' do
      expect(Route.by_user(key: @user.id).to_a.size).to eq(4)
    end
  end

  context 'Relationships' do
    it 'returns the parent company' do
      expect(@route.company.name).to eq(@company.name)
      expect(@route.company).to eq(@company)
    end

    it 'returns the parent user' do
      expect(@route.user.sync_user).to eq(@user.sync_user)
      expect(@route.user).to eq(@user)
    end

    it 'cannot update company id' do
      @route.update(company_id: 'other_company_id')
      expect(@route.errors.first[0]).to eq(:company_id)
      expect(@route.errors.first[1]).to eq(I18n.t('couchbase.errors.models.user_track.company_id_immutable'))
      @route.update(company_id: @company.id)
    end
  end
end

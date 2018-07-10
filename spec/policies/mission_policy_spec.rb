describe MissionPolicy, basic: true do

  before(:all) do
    @company = create(:company, name: 'mapo-company')
    @user = create(:user, company: @company)
    @route = create(:route, company: @company, user: @user, name: 'mapo-route')
    @mission = create(:mission, company: @company, user: @user, route: @route)

    @other_company = create(:company, name: 'mapo-other-company')
    @other_user = create(:user, company: @other_company,)
    @other_route = create(:route, company: @company, user: @user, name: 'mapo-route')
    @other_mission = create(:mission, company: @other_company, user: @other_user, route: @other_route)
  end

  context 'for a visitor' do
    let(:current_user) { nil }
    let(:user) { nil }

    subject { MissionPolicy.new(user, @mission) }

    it { should_not grant(:show) }
    it { should_not grant(:create) }
    it { should_not grant(:update) }
    it { should_not grant(:destroy) }
  end

  context 'for another user from other company' do
    let(:user) { @other_user }

    subject { MissionPolicy.new(user, @mission) }

    it { should_not grant(:show) }
    it { should_not grant(:create) }
    it { should_not grant(:update) }
    it { should_not grant(:destroy) }
  end

  context 'for the current user' do
    let(:user) { @user }

    subject { MissionPolicy.new(user, @mission) }

    it { should grant(:show) }
    it { should grant(:create) }
    it { should grant(:update) }
    it { should grant(:destroy) }
  end

end

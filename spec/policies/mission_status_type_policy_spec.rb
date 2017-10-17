describe MissionStatusTypePolicy, basic: true do

  before(:all) do
    @company = create(:company, name: 'mapo-company')
    @user = create(:user, company: @company)
    @mission_status_type = create(:mission_status_type, company: @company)

    @other_company = create(:company, name: 'mapo-company')
    @other_user = create(:user, company: @other_company)
    @other_mission_status_type = create(:mission_status_type, company: @other_company)
  end

  context 'for a visitor' do
    let(:current_user) { nil }
    let(:user) { nil }

    subject { MissionStatusTypePolicy.new(user, @mission_status_type) }

    it { should_not grant(:show) }
    it { should_not grant(:create) }
    it { should_not grant(:update) }
    it { should_not grant(:destroy) }
  end

  context 'for another user from other company' do
    let(:user) { @other_user }

    subject { MissionStatusTypePolicy.new(user, @mission_status_type) }

    it { should_not grant(:show) }
    it { should_not grant(:create) }
    it { should_not grant(:update) }
    it { should_not grant(:destroy) }
  end

  context 'for the current user' do
    let(:user) { @user }

    subject { MissionStatusTypePolicy.new(user, @mission_status_type) }

    it { should grant(:show) }
    it { should grant(:create) }
    it { should grant(:update) }
    it { should grant(:destroy) }
  end

end

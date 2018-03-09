describe MissionActionTypePolicy, basic: true do

  before(:all) do
    @company = create(:company, name: 'mapo-company')
    @user = create(:user, company: @company)
    @previous_mission_status_type = create(:mission_status_type, company: @company)
    @next_mission_status_type = create(:mission_status_type, company: @company)
    @mission_action_type = build(:mission_action_type,
                                    company: @company,
                                    previous_mission_status_type: @previous_mission_status_type,
                                    next_mission_status_type: @next_mission_status_type)

    @other_company = create(:company, name: 'mapo-other-company')
    @other_user = create(:user, company: @other_company)
    @other_previous_mission_status_type = create(:mission_status_type, company: @company)
    @other_next_mission_status_type = create(:mission_status_type, company: @company)
    @other_mission_action_type = create(:mission_action_type,
                                          company: @other_company,
                                          previous_mission_status_type: @other_previous_mission_status_type,
                                          next_mission_status_type: @other_next_mission_status_type)
  end

  context 'for a visitor' do
    let(:current_user) { nil }
    let(:user) { nil }

    subject { MissionActionTypePolicy.new(user, @mission_action_type) }

    it { should_not grant(:show) }
    it { should_not grant(:create) }
    it { should_not grant(:update) }
    it { should_not grant(:destroy) }
  end

  context 'for another user from other company' do
    let(:user) { @other_user }

    subject { MissionActionTypePolicy.new(user, @mission_action_type) }

    it { should_not grant(:show) }
    it { should_not grant(:create) }
    it { should_not grant(:update) }
    it { should_not grant(:destroy) }
  end

  context 'for the current user' do
    let(:user) { @user }

    subject { MissionActionTypePolicy.new(user, @mission_action_type) }

    it { should grant(:show) }
    it { should grant(:create) }
    it { should grant(:update) }
    it { should grant(:destroy) }
  end

end

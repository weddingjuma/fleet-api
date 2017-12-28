describe UserCurrentLocationPolicy, basic: true do

  before(:all) do
    @company = create(:company, name: 'mapo-company')
    @user = create(:user, company: @company)

    @current_location = create(:user_current_location, company: @company, user: @user, location_detail: {
      lat: Random.rand(43.0..50.0),
      lon: Random.rand(-2.0..6.0),
      date: Time.now.strftime('%FT%T.%L%:z')
    })

    @other_company = create(:company, name: 'mapo-other-company')
    @other_user = create(:user, company: @other_company)
  end

  context 'for a visitor' do
    let(:current_user) { nil }
    let(:user) { nil }

    subject { UserCurrentLocationPolicy.new(user, @current_location) }

    it { should_not grant(:show) }
  end

  context 'for another user from other company' do
    let(:user) { @other_user }

    subject { UserCurrentLocationPolicy.new(user, @current_location) }

    it { should_not grant(:show) }
  end

  context 'for the current user' do
    let(:user) { @user }

    subject { UserCurrentLocationPolicy.new(user, @current_location) }

    it { should grant(:show) }
  end

end

describe CompanyPolicy, basic: true do

  before(:all) do
    @company = create(:company, name: 'mapo-company')
    @user = create(:user, company: @company)

    @other_company = create(:company, name: 'mapo-other-company')
    @other_user = create(:user, company: @other_company)
  end

  context 'for a visitor' do
    let(:current_user) { nil }
    let(:user) { nil }

    subject { CompanyPolicy.new(user, @company) }

    it { should_not grant(:show) }
  end

  context 'for another user from other company' do
    let(:user) { @other_user }

    subject { CompanyPolicy.new(user, @company) }

    it { should_not grant(:show) }
  end

  context 'for the current user' do
    let(:user) { @user }

    subject { CompanyPolicy.new(user, @company) }

    it { should grant(:show) }
  end

end

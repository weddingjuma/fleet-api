class CompanyPolicy
  attr_reader :current_user, :company

  def initialize(current_user, company)
    raise Pundit::NotAuthorizedError unless company
    @current_user = current_user
    @company = company
  end

  def index?
    connected?
  end

  def show?
    same_company?
  end

  private

  def connected?
    !!@current_user
  end

  def same_company?
    @current_user && @company == @current_user.company
  end
end

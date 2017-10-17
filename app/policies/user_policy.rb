class UserPolicy
  attr_reader :current_user, :user

  def initialize(current_user, user)
    raise Pundit::NotAuthorizedError unless user
    @current_user = current_user
    @user         = user
  end

  def show?
    same_company?
  end

  def create?
    same_company?
  end

  def update?
    same_company?
  end

  def destroy?
    same_company?
  end

  private

  def same_company?
    @current_user && @user.company == @current_user.company
  end
end

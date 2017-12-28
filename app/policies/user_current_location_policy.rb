class UserCurrentLocationPolicy
  attr_reader :current_user, :current_location

  def initialize(current_user, current_location)
    raise Pundit::NotAuthorizedError unless current_location
    @current_user = current_user
    @current_location = current_location
  end

  def show?
    same_company?
  end

  private

  def same_company?
    @current_user && @current_location.company == @current_user.company
  end
end

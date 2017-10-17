class MissionStatusTypePolicy
  attr_reader :current_user, :mission_status_type

  def initialize(current_user, mission_status_type)
    raise Pundit::NotAuthorizedError unless mission_status_type
    @current_user = current_user
    @mission_status_type = mission_status_type
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
    @current_user && @mission_status_type.company == @current_user.company
  end
end

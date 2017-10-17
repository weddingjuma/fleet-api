class MissionStatusActionPolicy
  attr_reader :current_user, :mission_status_action

  def initialize(current_user, mission_status_action)
    raise Pundit::NotAuthorizedError unless mission_status_action
    @current_user = current_user
    @mission_status_action = mission_status_action
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
    @current_user && @mission_status_action.company == @current_user.company
  end
end

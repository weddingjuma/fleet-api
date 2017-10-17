class MissionPolicy
  attr_reader :current_user, :mission

  def initialize(current_user, mission)
    raise Pundit::NotAuthorizedError unless mission
    @current_user = current_user
    @mission = mission
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
    @current_user && @mission.company == @current_user.company
  end
end

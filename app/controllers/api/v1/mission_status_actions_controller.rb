module Api::V1
  class MissionStatusActionsController < ApiController
    after_action :verify_authorized

    def index
      mission_status_actions = if params[:user_id]
                               user = User.find(params[:user_id])
                               authorize user, :show?
                               user.company.mission_status_actions.to_a
                             end

      if mission_status_actions
        render json: mission_status_actions,
               each_serializer: MissionStatusActionSerializer
      else
        render body: nil, status: :not_found
      end
    end

    def create
      user = User.find(params[:user_id])
      mission_status_action = MissionStatusAction.new
      mission_status_action.assign_attributes(mission_status_action_params)
      mission_status_action.company = user.company
      authorize mission_status_action

      if mission_status_action.save
        render json: mission_status_action,
               serializer: MissionStatusActionSerializer
      else
        render json: mission_status_action.errors, status: :unprocessable_entity
      end
    end

    def update
      mission_status_action = MissionStatusAction.find(params[:id])
      mission_status_action.assign_attributes(mission_status_action_params)
      authorize mission_status_action

      if mission_status_action.save
        render json: mission_status_action,
               serializer: MissionStatusActionSerializer
      else
        render json: mission_status_action.errors, status: :unprocessable_entity
      end
    end

    def destroy
      mission_status_action = MissionStatusAction.find(params[:id])
      authorize mission_status_action

      if mission_status_action.destroy
        render json: mission_status_action,
               serializer: MissionStatusActionSerializer
      else
        render json: mission_status_action.errors, status: :unprocessable_entity
      end
    end

    private

    def mission_status_action_params
      params.permit(
        :label,
        :group,
        :previous_mission_status_type_id,
        :next_mission_status_type_id
      )
    end

  end
end

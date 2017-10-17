module Api::V1
  class MissionStatusTypesController < ApiController
    after_action :verify_authorized

    def index
      mission_status_types = if params[:user_id]
                               user = User.find(params[:user_id])
                               authorize user, :show?
                               user.company.mission_status_types.to_a
                             end

      if mission_status_types
        render json: mission_status_types,
               each_serializer: MissionStatusTypeSerializer
      else
        render body: nil, status: :not_found
      end
    end

    def create
      user = User.find(params[:user_id])
      mission_status_type = MissionStatusType.new
      mission_status_type.assign_attributes(mission_status_type_params)
      mission_status_type.company = user.company
      authorize mission_status_type

      if mission_status_type.save
        render json: mission_status_type,
               serializer: MissionStatusTypeSerializer
      else
        render json: mission_status_type.errors, status: :unprocessable_entity
      end
    end

    def update
      mission_status_type = MissionStatusType.find(params[:id])
      mission_status_type.assign_attributes(mission_status_type_params)
      authorize mission_status_type

      if mission_status_type.save
        render json: mission_status_type,
               serializer: MissionStatusTypeSerializer
      else
        render json: mission_status_type.errors, status: :unprocessable_entity
      end
    end

    def destroy
      mission_status_type = MissionStatusType.find(params[:id])
      authorize mission_status_type

      if mission_status_type.destroy
        render json: mission_status_type,
               serializer: MissionStatusTypeSerializer
      else
        render json: mission_status_type.errors, status: :unprocessable_entity
      end
    end

    private

    def mission_status_type_params
      params.permit(
        :color,
        :label
      )
    end

  end
end

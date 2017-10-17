module Api::V1
  class MissionsController < ApiController
    after_action :verify_authorized

    # get_missions
    def index
      missions = if params[:user_id]
                   user = User.find(params[:user_id])
                   authorize user, :show?
                   user.missions.to_a
                 else
                   Mission.all.to_a
                 end

      if missions
        render json: missions,
               each_serializer: MissionSerializer
      else
        render body: nil, status: :not_found
      end
    end

    # set_mission
    def create
      user = User.find(params[:user_id])
      mission = Mission.new
      mission.assign_attributes(mission_params)
      mission.user = user
      mission.company = user.company
      authorize mission

      if mission.save
        render json: mission,
               serializer: MissionSerializer
      else
        render json: mission.errors, status: :unprocessable_entity
      end
    end

    def update
      mission = Mission.find(params[:id])
      mission.assign_attributes(mission_params)
      authorize mission

      if mission.save
        render json: mission,
               serializer: MissionSerializer
      else
        render json: mission.errors, status: :unprocessable_entity
      end
    end

    # delete_mission
    def destroy
      mission = Mission.find(params[:id])
      authorize mission

      if mission.destroy
        render json: mission,
               serializer: MissionSerializer
      else
        render json: mission.errors, status: :unprocessable_entity
      end
    end

    private

    def mission_params
      params.permit(
        :name,
        :date,
        :comment,
        :phone,
        :reference,
        :duration,
        location: [
          :lat,
          :lon
        ],
        address: [
          :city,
          :country,
          :detail,
          :postalcode,
          :state,
          :street
        ],
        time_windows: [
          :start,
          :end
        ]
      )
    end

  end
end

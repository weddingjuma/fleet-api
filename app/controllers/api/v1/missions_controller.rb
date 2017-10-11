module Api::V1
  class MissionsController < ApiController

    # TODO
    # get_missions
    def index
      render json: Mission.all.to_a,
             each_serializer: MissionSerializer
    end

    # TODO
    # set_mission
    def create
      # vehicle_id
      # mission_params

      render json: Mission.all.to_a,
             each_serializer: MissionSerializer
    end

    # TODO
    # delete_mission
    def destroy
      # mission_id

      render json: Mission.all.to_a,
             each_serializer: MissionSerializer
    end

  end

  private

  def mission_params
    params.require(:mission).permit(
      :comment,
      :date,
      :name,
      :phone,
      :reference,
      :duration,
      owners: [],
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

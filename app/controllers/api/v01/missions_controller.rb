module Api::V01
  class MissionsController < ApiController
    after_action :verify_authorized, except: [:index]

    # get_missions
    def index
      missions = if params[:user_id]
                   user = User.find_by(params[:user_id])
                   authorize user, :show?
                   user.missions.to_a
                 else
                   Mission.by_company(key: @current_user.company.id).to_a
                 end

      if missions
        render json: missions,
               root: 'missions',
               each_serializer: MissionSerializer
      else
        render body: nil, status: :not_found
      end
    end

    # set_mission
    def create
      user = User.find_by(params[:user_id])
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

    def create_multiples
      user = User.find_by(params[:user_id])

      missions = missions_params.map do |mission_params|
        # Override mission if already exists
        mission = Mission.by_external_ref(key: [user.company_id, mission_params['external_ref']]).to_a.first || Mission.new
        mission.assign_attributes(mission_params)
        mission.user = user
        mission.company = user.company
        authorize mission, :create?
        mission.save ? mission : nil
      end.compact

      if missions.present?
        render json: missions,
               each_serializer: MissionSerializer
      else
        render json: [], status: :unprocessable_entity,
               root: 'missions'
      end
    end

    def update
      mission = Mission.find_by(params[:id], @current_user&.company_id)
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
      mission = Mission.find_by(params[:id], @current_user&.company_id)
      authorize mission

      if mission.destroy
        render json: mission,
               serializer: MissionSerializer,
               destroy: true
      else
        render json: mission.errors, status: :unprocessable_entity
      end
    end

    def destroy_multiples
      if params['end_date']
        user = User.find_by(params['user_id'])
        ids = Mission.filter_by_date(user.id, params['end_date'], params['start_date'])
      elsif params['ids']
        ids = params['ids'].is_a?(String) ? params['ids'].split(',') : params['ids']
      else
        ids = []
      end

      ids.map do |id|
        mission = Mission.find_by(id, @current_user&.company_id) rescue nil
        if mission
          authorize mission, :destroy?
          mission.destroy
        end
      end

      head :no_content
    end

    private

    def mission_params
      params.permit(
        :external_ref,
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

    def missions_params
      params.permit(_json: [
        mission_attributes
      ]
      )[:_json]
    end

    def mission_attributes
      [
        :external_ref,
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
      ]
    end

  end
end

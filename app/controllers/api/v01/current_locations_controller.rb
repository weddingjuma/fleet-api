module Api::V01
  class CurrentLocationsController < ApiController
    after_action :verify_authorized, except: [:index]

    # get_vehicles_pos
    def index
      current_locations = CurrentLocation.by_company(key: @current_user.company.id).to_a

      render json: current_locations,
             each_serializer: CurrentLocationSerializer
    end

    def show
      user = User.find_by(params[:user_id])
      current_location = user&.current_location
      authorize current_location

      if current_location
        render json: current_location,
               serializer: CurrentLocationSerializer
      else
        render body: nil, status: :not_found
      end
    end

  end
end

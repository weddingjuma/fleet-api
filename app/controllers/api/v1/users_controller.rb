module Api::V1
  class UsersController < ApiController

    # get_vehicles / get_vehicles_pos
    def index
      render json: User.all.to_a,
             each_serializer: UserSerializer
    end

    # check_auth
    def show
      user = User.by_user(key: params[:id]).to_a.first

      if user
        render json: user,
               serializer: UserSerializer
      else
        render body: nil, status: 404
      end
    end

  end
end

module Api::V1
  class UsersController < ApiController
    after_action :verify_authorized, except: [:index]

    # get_vehicles / get_vehicles_pos
    def index
      users = User.by_company(key: @current_user.company.id).to_a

      users = users.select(&:vehicle) if params[:with_vehicle]

      render json: users,
             each_serializer: UserSerializer
    end

    # check_auth
    def show
      user = User.find_by(params[:id])
      authorize user

      if user
        render json: user,
               serializer: UserSerializer
      else
        render body: nil, status: 404
      end
    end

    def create
      user = User.new
      user.assign_attributes(user_params)
      user.company = @current_user.company
      authorize user

      if user.save
        render json: user,
               serializer: UserSerializer
      else
        render json: user.errors, status: :unprocessable_entity
      end
    end

    def update
      user = User.find_by(params[:id])
      user.assign_attributes(user_params)
      authorize user

      if user.save
        render json: user,
               serializer: UserSerializer
      else
        render json: user.errors, status: :unprocessable_entity
      end
    end

    def destroy
      user = User.find_by(params[:id])
      authorize user

      if user.destroy
        render json: user,
               serializer: UserSerializer
      else
        render json: user.errors, status: :unprocessable_entity
      end
    end

    private

    def user_params
      params.permit(
        :sync_user,
        :email,
        :password,
        :vehicle,
        roles: []
      )
    end

  end
end

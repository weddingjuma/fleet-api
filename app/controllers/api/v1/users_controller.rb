module Api::V1
  class UsersController < ApiController
    after_action :verify_authorized, except: [:index]

    # get_vehicles / get_vehicles_pos
    def index
      render json: User.by_company(key: @current_user.company.id).to_a,
             each_serializer: UserSerializer
    end

    # check_auth
    def show
      user = User.find(params[:id])
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
      user = User.find(params[:id])
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
      user = User.find(params[:id])
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
      params.require(:user).permit(
        :sync_user,
        :email,
        :password,
        roles: []
      )
    end

  end
end

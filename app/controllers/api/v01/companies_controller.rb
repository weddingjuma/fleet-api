module Api::V01
  class CompaniesController < ApiController
    before_action :authenticate_admin, only: [:index]
    skip_before_action :authenticate, only: [:index]

    after_action :verify_authorized

    def index
      authorize Company

      render json: Company.all.to_a,
             each_serializer: CompanySerializer
    end

    def show
      company = nil
      if params[:user_id]
        user = User.find_by(params[:user_id])
        authorize user
        company = user&.company
      elsif params[:id]
        company = Company.find(params[:id])
        authorize company
      end

      if company
        render json: company,
               serializer: CompanySerializer
      else
        render body: nil, status: :not_found
      end
    end

    private

    def company_params
      params.permit(
        :name
      )
    end

  end
end

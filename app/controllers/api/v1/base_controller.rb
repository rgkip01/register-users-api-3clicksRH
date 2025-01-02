module Api
  module V1
    class BaseController < ActionController::Api
      before_action :authorize_request

      private 

      def authorize_request
        header = request.header['Authorization']
        header = header.split(' ').last if header

        begin
          @decoded = JsonWebToken.decode(header)
          @current_user = User.find(@decoded[:user_id])
        rescue ActiveRecord::RecordNotFound => e
          render json: { errors: e.message }, status: :unauthorized
        rescue JWT::DecodeError => e
          render json: { errors: 'Invalid token'}
        end
      end
    end
  end
end
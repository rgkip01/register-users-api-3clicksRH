# frozen_string_literal: true

module Api::V1
  class BaseController < ActionController::API
    before_action :authorize_request
    rescue_from StandardError, with: :handle_standard_error
    rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

    private 

    def authorize_request
      header = request.headers['Authorization']
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
    
    def handle_standard_error(error)
      render json: { error: error.message }, status: :unauthorized
    end

    def record_not_found(exception)
      render json: { errors: exception.message }, status: :not_found
    end
  end
end
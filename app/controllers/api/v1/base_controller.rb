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

      expected_token = ENV['JWT_SECRET'] # Token fixo definido no backend

      return if header == expected_token

      render json: { errors: 'Unauthorized' }, status: :unauthorized
    end

    def handle_standard_error(error)
      render json: { error: error.message }, status: :internal_server_error
    end

    def record_not_found(exception)
      render json: { errors: exception.message }, status: :not_found
    end
  end
end

# frozen_string_literal: true

module Api::V1
  class UsersController < BaseController
    before_action :authorize_request, except: [:create]
    before_action :set_user, only: [:show, :update, :destroy]

    def index 
      users = User.all
      render json: UserSerializer.new(users).serialized_json, status: :ok
    end

    def show
      if @user
        render json: UserSerializer.new(@user).serialized_json
      else
        render json: { errors: 'User not found' }, status: :not_found
      end
    end
    

    def create
      user = User.new(user_params)
      
      if user.save
        create_addresses(user, address_params)
        render json: UserSerializer.new(user).serialized_json, status: :created
      else
        render json: {errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def update
      if @user.update(user_params)
        @user.addresses.destroy_all
        create_addresses(@user, address_params)
        render json: UserSerializer.new(@user).serialized_json
      else
        render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def destroy
      @user.destroy

      head :no_content
    end

    def search
      query = params[:query]

      users = User.where(
        'name ILIKE :query OR document ILIKE :query OR date_of_birth = :date_query',
        query: "%#{query}%",
        date_query: valid_date?(query) ? query : nil
      )
    
      render json: UserSerializer.new(users).serialized_json
    end

    def valid_date?(string)
      Date.parse(string)
      true
    rescue ArgumentError
      false
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:data).require(:attributes).permit(
        :name,
        :email,
        :document,
        :date_of_birth
      )
    end

    def address_params
      params[:addresses] || []
    end

    def create_addresses(user, addresses)
      return [] unless params.dig(:data, :relationships, :addresses, :data)

      params[:data][:relationships][:addresses][:data].map do |address|
        user.addresses.create!(address[:attributes].permit(:street, :city, :state, :zip_code, :country, :complement))
      end
    rescue ActiveRecord::RecordInvalid => e
      render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
    end
  end
end
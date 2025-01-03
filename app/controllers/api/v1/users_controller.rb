# frozen_string_literal: true

module Api::V1
  class UsersController < BaseController
    before_action :set_user, only: [:show, :update, :destroy]

    def index 
      users = User.all
      render json: UserSerializer.new(users).serializer_json
    end

    def show 
      render json: UserSerializer.new(@user).serializer_json
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
      if @user.udpate(user_params)
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
      users = User.where(
        'name ILIKE ? OR document ILIKE ? OR date_of_birth = ?',
        "%#{params[:query]}%", "%#{params[:query]}%", params[:query]
      )

      render json: UserSerializer.new(users).serialized_json
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(
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
      addresses.each do |address|
        user.addresses.create!(address.permit(:street, :city, :state, :zip_code, :country, :complement))
      end
    rescue ActiveRecord::RecordInvalid => e
      render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
    end
  end
end
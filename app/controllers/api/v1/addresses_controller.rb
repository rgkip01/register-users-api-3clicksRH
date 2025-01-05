# frozen_string_literal: true

module Api
  module V1
    class AddressesController < BaseController
      before_action :set_user
      before_action :set_address, only: [:show, :update, :destroy]

      def index
        addresses = @user.addresses
        render json: AddressSerializer.new(addresses).serialized_json
      end

      def show
        render json: AddressSerializer.new(@address).serialized_json
      end

      def create
        address = @user.addresses.new(address_params)

        if address.save
          render json: AddressSerializer.new(address).serialized_json, status: :created
        else
          render json: { errors: address.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @address.update(address_params)
          render json: AddressSerializer.new(@address).serialized_json
        else
          render json: { errors: @address.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @address.destroy
        head :no_content
      end

      private

      def set_user
        @user = User.find(params[:user_id])
      rescue ActiveRecord::RecordNotFound
        render json: { errors: "Couldn't find User with 'id'=#{params[:user_id]}" }, status: :not_found
      end

      def set_address
        @address = @user.addresses.find(params[:id])
      end

      def address_params
        params.require(:data).require(:attributes).permit(:street, :city, :state, :zip_code, :country, :complement)
      end
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::BaseController, type: :controller do
  controller(described_class) do
    def test_action
      render json: { message: 'Authorized' }
    end
  end

  before do
    routes.draw { get 'test_action' => 'api/v1/base#test_action' }
  end

  let(:valid_token) { ENV['JWT_SECRET'] }
  let(:invalid_token) { 'invalid.token.here' }

  describe '#authorize_request' do
    context 'with a valid token' do
      it 'authorizes the request' do
        request.headers['Authorization'] = "Bearer #{valid_token}"

        get :test_action
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['message']).to eq('Authorized')
      end
    end

    context 'with a missing token' do
      it 'returns unauthorized status' do
        get :test_action
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['errors']).to eq('Unauthorized')
      end
    end

    context 'with an invalid token' do
      it 'returns unauthorized status' do
        request.headers['Authorization'] = "Bearer #{invalid_token}"

        get :test_action
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['errors']).to eq('Unauthorized')
      end
    end
  end
end

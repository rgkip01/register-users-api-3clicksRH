# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::BaseController, type: :controller do
  controller(Api::V1::BaseController) do
    def test_action
      render json: { message: 'Authorized' }
    end
  end

  before do
    routes.draw { get 'test_action' => 'api/v1/base#test_action' }
  end

  let(:user) { create(:user) }
  let(:valid_token) { JsonWebToken.encode(user_id: user.id) }
  let(:invalid_token) { 'invalid.token.here' }
  let(:non_existent_user_token) { JsonWebToken.encode(user_id: 777) }

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
        expect(JSON.parse(response.body)['error']).to eq('Token ausente')
      end
    end

    context 'with a token for a non-existent user' do
      it 'returns unauthorized status' do
        request.headers['Authorization'] = "Bearer #{non_existent_user_token}"

        get :test_action

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['errors']).to match(/Couldn't find User/)
      end
    end
  end
end

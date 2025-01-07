# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :controller do
  let!(:user) { create(:user) }
  let!(:user2) { create(:user) }
  let!(:addresses) { create_list(:address, 2, user: user) }
  let!(:address) { create(:address, user: user2) }
  let(:valid_token) { ENV['JWT_SECRET'] }
  let(:invalid_token) { 'invalid.token.here' }

  let(:valid_attributes) do
    {
      data: {
        type: 'users',
        attributes: {
          name: 'Rafa Abreu',
          email: 'rafa.abreu@example.com',
          document: '12345678901',
          date_of_birth: '1990-11-05'
        },
        relationships: {
          addresses: {
            data: [
              {
                type: 'addresses',
                attributes: {
                  street: 'Street 1',
                  city: 'City 1',
                  state: 'ST',
                  zip_code: '00000-000',
                  country: 'Country 1'
                }
              }
            ]
          }
        }
      }
    }
  end

  before do
    request.headers['Authorization'] = "Bearer #{valid_token}"
  end

  describe 'GET #index' do
    context 'when there are users' do
      it 'returns a list of users with addresses' do
        get :index

        expect(response).to have_http_status(:ok)
        parsed_response = JSON.parse(response.body)

        expect(parsed_response['data'].size).to eq(2)

        user_ids = parsed_response['data'].map { |u| u['id'].to_i }
        expect(user_ids).to include(user.id, user2.id)
      end
    end

    context 'when there are no users' do
      it 'returns an empty list' do
        User.destroy_all

        get :index

        expect(response).to have_http_status(:ok)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['data']).to be_empty
      end
    end
  end

  describe 'GET #show' do
    context 'when the user exists' do
      it 'returns the requested user with addresses' do
        get :show, params: { id: user.id }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['data']['id']).to eq(user.id.to_s)
      end
    end

    context 'when the user does not exist' do
      it 'returns a not found error' do
        get :show, params: { id: 777 }
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['errors']).to eq("Couldn't find User with 'id'=777")
      end
    end
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      it 'creates a new user with addresses' do
        expect do
          post :create, params: valid_attributes, as: :json
        end.to change(User, :count).by(1)
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['data']['attributes']['name']).to eq('Rafa Abreu')
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid attributes' do
      it 'updates the user and their addresses' do
        put :update, params: { id: user.id, data: { type: 'users', attributes: { name: 'Rafael C. Abreu' } } },
                     as: :json
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['data']['attributes']['name']).to eq('Rafael C. Abreu')
      end
    end

    context 'with invalid attributes' do
      it 'returns an error when required fields are missing' do
        put :update, params: { id: user.id, data: { type: 'users', attributes: { name: '' } } }, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).not_to be_empty
      end
    end

    context 'when the user does not exist' do
      it 'returns a not found error' do
        put :update, params: { id: 123, data: { type: 'users', attributes: { name: 'Rafael C. Abreu' } } }, as: :json
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['errors']).to eq("Couldn't find User with 'id'=123")
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when the user exists' do
      it 'deletes the user and their addresses' do
        expect do
          delete :destroy, params: { id: user.id }
        end.to change(User, :count).by(-1)
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when the user does not exist' do
      it 'returns a not found error' do
        delete :destroy, params: { id: 123 }
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['errors']).to eq("Couldn't find User with 'id'=123")
      end
    end
  end

  describe 'GET #search' do
    context 'when users match the query' do
      it 'returns users matching the query by name' do
        get :search, params: { q: user.name }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['data'].size).to eq(1)
      end

      it 'returns users matching the query by document' do
        get :search, params: { q: user.document }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['data'].size).to eq(1)
      end

      it 'returns users matching the query by date of birth' do
        get :search, params: { q: user.date_of_birth.to_s }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['data'].size).to eq(1)
      end
    end

    context 'when the query is not a valid date' do
      it 'does not raise an error and returns no users for invalid date format' do
        get :search, params: { q: 'invalid-date' }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['data']).to be_empty
      end
    end
  end
end

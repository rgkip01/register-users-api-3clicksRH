# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::AddressesController, type: :controller do
  let!(:user) { create(:user) }
  let!(:address) { create(:address, user: user) }
  let(:valid_token) { ENV['JWT_SECRET'] }

  before do
    request.headers['Authorization'] = "Bearer #{valid_token}"
  end

  describe 'GET #show' do
    it 'returns the requested address' do
      get :show, params: { user_id: user.id, id: address.id }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['data']['id']).to eq(address.id.to_s)
    end
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      it 'creates a new address' do
        expect do
          post :create, 
          params: { 
            user_id: user.id,
            data: { 
              type: 'addresses',
              attributes: { 
                street: 'New Street',
                city: 'New City',
                state: 'NS',
                zip_code: '12345-678',
                country: 'New Country' 
              } 
            }
          }, as: :json
        end.to change(Address, :count).by(1)
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['data']['attributes']['street']).to eq('New Street')
      end
    end

    context 'with invalid attributes' do
      it 'returns an error when required fields are missing' do
        post :create, params: { user_id: user.id, data: { type: 'addresses', attributes: { street: '' } } }, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).not_to be_empty
      end
    end
  end


  describe 'PUT #update' do
    it 'updates the address with valid attributes' do
      put :update, params: { user_id: user.id, id: address.id, data: { type: 'addresses', attributes: { city: 'Updated City' } } }, as: :json
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['data']['attributes']['city']).to eq('Updated City')
    end
  end

  describe 'DELETE #destroy' do
    it 'deletes the address' do
      expect do
        delete :destroy, params: { user_id: user.id, id: address.id }
      end.to change(Address, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end
  end
end
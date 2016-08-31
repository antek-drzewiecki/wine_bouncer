# frozen_string_literal: true

require 'rails_helper'
require 'json'

describe Api::MountedProtectedApiUnderTest, type: :api do
  let(:user) { FactoryGirl.create :user }
  let(:token) { FactoryGirl.create :clientless_access_token, resource_owner_id: user.id, scopes: 'public' }

  before(:example) do
    WineBouncer.configure do |c|
      c.auth_strategy = :protected_but_swagger

      c.define_resource_owner do
        User.find(doorkeeper_access_token.resource_owner_id) if doorkeeper_access_token
      end
    end
  end

  context 'swagger endpoint' do
    it 'allows to call the swagger endpoint without token' do
      get '/protected_api/endpoint/for/swagger'

      expect(last_response.status).to eq(200)
      json = JSON.parse(last_response.body)

      expect(json).to have_key('hello')
      expect(json['hello']).to eq('swagger')
    end

    it 'allows to call the swagger endpoint with token' do
      get '/protected_api/endpoint/for/swagger', nil, 'HTTP_AUTHORIZATION' => "Bearer #{token.token}"

      expect(last_response.status).to eq(200)
      json = JSON.parse(last_response.body)
      expect(json).to have_key('hello')
      expect(json['hello']).to eq('swagger')
    end
  end
end

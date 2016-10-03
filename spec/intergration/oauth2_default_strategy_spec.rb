# frozen_string_literal: true

require 'rails_helper'
require 'json'

describe Api::MountedDefaultApiUnderTest, type: :api do
  let(:user) { FactoryGirl.create :user }
  let(:token) { FactoryGirl.create :clientless_access_token, resource_owner_id: user.id, scopes: 'public' }
  let(:unscoped_token) { FactoryGirl.create :clientless_access_token, resource_owner_id: user.id, scopes: '' }
  let(:custom_scope) { FactoryGirl.create :clientless_access_token, resource_owner_id: user.id, scopes: 'custom_scope' } #not a default scope

  before(:example) do
    WineBouncer.configure do |c|
      c.auth_strategy = :default

      c.define_resource_owner do |doorkeeper_access_token|
        User.find(doorkeeper_access_token.resource_owner_id) if doorkeeper_access_token
      end
    end
  end

  context 'tokens and scopes' do
    it 'gives access when the token and scope are correct' do
      get '/default_api/protected', nil, 'HTTP_AUTHORIZATION' => "Bearer #{token.token}"

      expect(last_response.status).to eq(200)
      json = JSON.parse(last_response.body)
      expect(json).to have_key('hello')
    end

    it 'gives access when tokens are correct and an non doorkeeper default scope is used.' do
      get '/default_api/oauth2_custom_scope', nil, 'HTTP_AUTHORIZATION' => "Bearer #{custom_scope.token}"

      expect(last_response.status).to eq(200)
      json = JSON.parse(last_response.body)
      expect(json).to have_key('hello')
      expect(json['hello']).to eq('oauth2_custom_scope')
    end

    it 'raises an authentication error when the token is invalid' do
      get '/default_api/protected', nil, 'HTTP_AUTHORIZATION' => "Bearer #{token.token}-invalid"
      expect(last_response.status).to eq(401)
      json = JSON.parse(last_response.body)
      expect(json).to have_key('error')
    end

    it 'raises an oauth authentication error when no token is given' do
      get '/default_api/protected'
      expect(last_response.status).to eq(401)
      json = JSON.parse(last_response.body)
      expect(json).to have_key('error')
    end

    it 'raises an auth forbidden authentication error when the user scope is not correct' do
      get '/default_api/protected_with_private_scope', nil, 'HTTP_AUTHORIZATION' => "Bearer #{token.token}"
      expect(last_response.status).to eq(403)
      json = JSON.parse(last_response.body)
      expect(json).to have_key('error')
    end
  end

  context 'unprotected endpoint' do
    it 'allows to call an unprotected endpoint without token' do
      get '/default_api/unprotected'
      expect(last_response.status).to eq(200)
      json = JSON.parse(last_response.body)
      expect(json).to have_key('hello')
      expect(json['hello']).to eq('unprotected world')
    end

    it 'allows to call an unprotected endpoint with token' do
      get '/default_api/unprotected', nil, 'HTTP_AUTHORIZATION' => "Bearer #{token.token}"
      expect(last_response.status).to eq(200)
      json = JSON.parse(last_response.body)
      expect(json).to have_key('hello')
      expect(json['hello']).to eq('unprotected world')
    end
  end

  context 'protected_without_scopes' do
    it 'allows to call an protected endpoint without scopes' do
      get '/default_api/protected_without_scope', nil, 'HTTP_AUTHORIZATION' => "Bearer #{token.token}"
      expect(last_response.status).to eq(200)
      json = JSON.parse(last_response.body)
      expect(json).to have_key('hello')
      expect(json['hello']).to eq('protected unscoped world')
    end

    it 'raises an error when an protected endpoint without scopes is called without token ' do
      get '/default_api/protected_without_scope'
      expect(last_response.status).to eq(401)
      json = JSON.parse(last_response.body)
      expect(json).to have_key('error')
    end

    it 'raises an error because the user does not have the default scope' do
      get '/default_api/protected_without_scope', nil, 'HTTP_AUTHORIZATION' => "Bearer #{unscoped_token.token}"
      expect(last_response.status).to eq(403)
      json = JSON.parse(last_response.body)
      expect(json).to have_key('error')
    end
  end

  context 'oauth2_dsl' do
    it 'allows to call an protected endpoint without scopes' do
      get '/default_api/oauth2_dsl', nil, 'HTTP_AUTHORIZATION' => "Bearer #{token.token}"
      expect(last_response.status).to eq(200)
      json = JSON.parse(last_response.body)
      expect(json).to have_key('hello')
      expect(json['hello']).to eq('oauth2 dsl')
    end

    it 'raises an error when an protected endpoint without scopes is called without token ' do
      get '/default_api/oauth2_dsl'
      expect(last_response.status).to eq(401)
      json = JSON.parse(last_response.body)
      expect(json).to have_key('error')
    end

    context 'without parameters' do
      it 'accepts tokens with default scopes' do
        get '/swagger_api/oauth2_dsl_default_scopes', nil, 'HTTP_AUTHORIZATION' => "Bearer #{token.token}"
        expect(last_response.status).to eq(200)
        json = JSON.parse(last_response.body)
        expect(json).to have_key('hello')
        expect(json['hello']).to eq('oauth dsl default scopes')
      end

      it 'raises an error when an protected endpoint without scopes is called without token ' do
        get '/default_api/oauth2_dsl_default_scopes'
        expect(last_response.status).to eq(401)
        json = JSON.parse(last_response.body)
        expect(json).to have_key('error')
      end

      it 'raises an error when token scopes are not default scopes ' do
        get '/default_api/oauth2_dsl_default_scopes', nil, 'HTTP_AUTHORIZATION' => "Bearer #{custom_scope.token}"
        expect(last_response.status).to eq(403)
        json = JSON.parse(last_response.body)
        expect(json).to have_key('error')
      end
    end

    context 'custom scopes' do
      it 'allows to call custom scopes' do
        get '/default_api/oauth2_dsl_custom_scope', nil, 'HTTP_AUTHORIZATION' => "Bearer #{custom_scope.token}"
        expect(last_response.status).to eq(200)
        json = JSON.parse(last_response.body)
        expect(json).to have_key('hello')
        expect(json['hello']).to eq('oauth2 dsl custom scope')
      end

      it 'raises an error when an protected endpoint without scopes is called without token ' do
        get '/default_api/oauth2_dsl_custom_scope'
        expect(last_response.status).to eq(401)
        json = JSON.parse(last_response.body)
        expect(json).to have_key('error')
      end

      it 'raises an error when token scopes do not match' do
        get '/default_api/oauth2_dsl_custom_scope', nil, 'HTTP_AUTHORIZATION' => "Bearer #{token.token}"
        expect(last_response.status).to eq(403)
        json = JSON.parse(last_response.body)
        expect(json).to have_key('error')
      end
    end

    context 'oauth2_dsl_multiple_scopes' do
      it 'allows call on the first scope' do
        scope_token = FactoryGirl.create :clientless_access_token, resource_owner_id: user.id, scopes: 'multiple'
        get '/default_api/oauth2_dsl_multiple_scopes', nil, 'HTTP_AUTHORIZATION' => "Bearer #{scope_token.token}"
        expect(last_response.status).to eq(200)
        json = JSON.parse(last_response.body)
        expect(json).to have_key('hello')
        expect(json['hello']).to eq('oauth2 dsl multiple scopes')
      end

      it 'allows call on the second scope' do
        scope_token = FactoryGirl.create :clientless_access_token, resource_owner_id: user.id, scopes: 'scopes'
        get '/default_api/oauth2_dsl_multiple_scopes', nil, 'HTTP_AUTHORIZATION' => "Bearer #{scope_token.token}"
        expect(last_response.status).to eq(200)
        json = JSON.parse(last_response.body)
        expect(json).to have_key('hello')
        expect(json['hello']).to eq('oauth2 dsl multiple scopes')
      end

      it 'raises an error scope does not match any of the scopes' do
        get '/default_api/oauth2_dsl_multiple_scopes'
        expect(last_response.status).to eq(401)
        json = JSON.parse(last_response.body)
        expect(json).to have_key('error')
      end
    end
  end

  context 'not_described_world' do
    it 'allows to call an endpoint without description' do
      get '/default_api/not_described_world'
      expect(last_response.status).to eq(200)
      json = JSON.parse(last_response.body)
      expect(json).to have_key('hello')
      expect(json['hello']).to eq('non described world')
    end
  end

  context 'resource_owner' do
    it 'is available in the endpoint' do
      get '/default_api/protected_user', nil, 'HTTP_AUTHORIZATION' => "Bearer #{token.token}"
      expect(last_response.status).to eq(200)
      json = JSON.parse(last_response.body)
      expect(json).to have_key('hello')
      expect(json['hello']).to eq(user.name)
    end
  end
end

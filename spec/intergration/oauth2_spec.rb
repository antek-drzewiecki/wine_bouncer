require 'rails_helper'
require 'json'

describe Api::MountedApiUnderTest, type: :api do

  let(:user) { FactoryGirl.create :user }
  let(:token) { FactoryGirl.create :clientless_access_token, resource_owner_id: user.id, scopes: "public" }
  let(:unscoped_token) { FactoryGirl.create :clientless_access_token, resource_owner_id: user.id, scopes: "" }

  context 'tokens and scopes' do
    it 'gives access when the token and scope are correct' do

      get '/api/protected', nil, 'HTTP_AUTHORIZATION' => "Bearer #{token.token}"

      expect(last_response.status).to eq(200)
      json = JSON.parse(last_response.body)
      expect(json).to have_key('hello')
    end

    it 'raises an authentication error when the token is invalid' do
      expect { get '/api/protected', nil, 'HTTP_AUTHORIZATION' => "Bearer #{token.token}-invalid" }.to raise_exception(WineBouncer::Errors::OAuthUnauthorizedError)
    end

    it 'raises an oauth authentication error when no token is given' do
      expect { get '/api/protected' }.to raise_exception(WineBouncer::Errors::OAuthUnauthorizedError)
    end

    it 'raises an auth forbidden authentication error when the user scope is not correct' do
      expect { get '/api/protected_with_private_scope', nil, 'HTTP_AUTHORIZATION' => "Bearer #{token.token}" }.to raise_exception(WineBouncer::Errors::OAuthForbiddenError)
    end
  end

  context 'unprotected endpoint' do
    it 'allows to call an unprotected endpoint without token' do
      get '/api/unprotected'

      expect(last_response.status).to eq(200)
      json = JSON.parse(last_response.body)

      expect(json).to have_key('hello')
      expect(json['hello']).to eq('unprotected world')
    end

    it 'allows to call an unprotected endpoint with token' do
      get '/api/unprotected', nil, 'HTTP_AUTHORIZATION' => "Bearer #{token.token}"

      expect(last_response.status).to eq(200)
      json = JSON.parse(last_response.body)
      expect(json).to have_key('hello')
      expect(json['hello']).to eq('unprotected world')
    end
  end

  context 'protected_without_scopes' do

    it 'allows to call an protected endpoint without scopes' do
      get '/api/protected_without_scope', nil, 'HTTP_AUTHORIZATION' => "Bearer #{token.token}"

      expect(last_response.status).to eq(200)
      json = JSON.parse(last_response.body)
      expect(json).to have_key('hello')
      expect(json['hello']).to eq('protected unscoped world')
    end

    it 'raises an error when an protected endpoint without scopes is called without token ' do
      expect { get '/api/protected_without_scope' }.to raise_exception(WineBouncer::Errors::OAuthUnauthorizedError)
    end

    it 'raises an error because the user does not have the default scope' do
      expect { get '/api/protected_without_scope', nil, 'HTTP_AUTHORIZATION' => "Bearer #{unscoped_token.token}" }.to raise_exception(WineBouncer::Errors::OAuthForbiddenError)
    end
  end

  context 'current_user' do
    it 'is available in the endpoint' do
      get '/api/protected_user', nil, 'HTTP_AUTHORIZATION' => "Bearer #{token.token}"

      expect(last_response.status).to eq(200)
      json = JSON.parse(last_response.body)

      expect(json).to have_key('hello')
      expect(json['hello']).to eq(user.name)
    end
  end

end

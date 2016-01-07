require 'rails_helper'
require 'json'

describe Api::MountedProtectedApiUnderTest, type: :api do
  let(:user) { FactoryGirl.create :user }
  let(:token) { FactoryGirl.create :clientless_access_token, resource_owner_id: user.id, scopes: 'public' }
  let(:unscoped_token) { FactoryGirl.create :clientless_access_token, resource_owner_id: user.id, scopes: '' }
  let(:custom_scope) { FactoryGirl.create :clientless_access_token, resource_owner_id: user.id, scopes: 'custom_scope' } #not a default scope

  before(:example) do
    WineBouncer.configure do |c|
      c.auth_strategy = :protected

      c.define_resource_owner do
        User.find(doorkeeper_access_token.resource_owner_id) if doorkeeper_access_token
      end
    end
  end

  context 'when WineBouncer is disabled' do
    before :all do
      WineBouncer.configure do |c|
        c.disable { true }
      end
    end

    after :all do
      WineBouncer.configure do |c|
        c.disable { false }
      end
    end

    it 'allows request to protected resource without token' do
      get '/protected_api/protected'
      expect(last_response.status).to eq(200)
      json = JSON.parse(last_response.body)
      expect(json).to have_key('hello')
    end
  end

  context 'tokens and scopes' do
    it 'gives access when the token and scope are correct' do
      get '/protected_api/protected', nil, 'HTTP_AUTHORIZATION' => "Bearer #{token.token}"

      expect(last_response.status).to eq(200)
      json = JSON.parse(last_response.body)
      expect(json).to have_key('hello')
    end

    it 'raises an authentication error when the token is invalid' do
      expect { get '/protected_api/protected', nil, 'HTTP_AUTHORIZATION' => "Bearer #{token.token}-invalid" }.to raise_exception(WineBouncer::Errors::OAuthUnauthorizedError)
    end

    it 'raises an oauth authentication error when no token is given' do
      expect { get '/protected_api/protected' }.to raise_exception(WineBouncer::Errors::OAuthUnauthorizedError)
    end

    it 'raises an auth forbidden authentication error when the user scope is not correct' do
      expect { get '/protected_api/protected_with_private_scope', nil, 'HTTP_AUTHORIZATION' => "Bearer #{token.token}" }.to raise_exception(WineBouncer::Errors::OAuthForbiddenError)
    end
  end

  context 'unprotected endpoint' do
    it 'allows to call an unprotected endpoint without token' do
      get '/protected_api/unprotected'

      expect(last_response.status).to eq(200)
      json = JSON.parse(last_response.body)

      expect(json).to have_key('hello')
      expect(json['hello']).to eq('unprotected world')
    end

    it 'allows to call an unprotected endpoint with token' do
      get '/protected_api/unprotected', nil, 'HTTP_AUTHORIZATION' => "Bearer #{token.token}"

      expect(last_response.status).to eq(200)
      json = JSON.parse(last_response.body)
      expect(json).to have_key('hello')
      expect(json['hello']).to eq('unprotected world')
    end
  end

  context 'protected_without_scopes' do
    it 'does not allow an unauthenticated user to call a protected endpoint' do
      expect { get '/protected_api/protected_without_scope' }.to raise_exception(WineBouncer::Errors::OAuthUnauthorizedError)
    end

    it 'allows to call an protected endpoint without scopes' do
      get '/protected_api/protected_without_scope', nil, 'HTTP_AUTHORIZATION' => "Bearer #{token.token}"

      expect(last_response.status).to eq(200)
      json = JSON.parse(last_response.body)
      expect(json).to have_key('hello')
      expect(json['hello']).to eq('protected unscoped world')
    end

    it 'raises an error when an protected endpoint without scopes is called without token ' do
      expect { get '/protected_api/protected_without_scope' }.to raise_exception(WineBouncer::Errors::OAuthUnauthorizedError)
    end

    it 'raises an error because the user does not have the default scope' do
      expect { get '/protected_api/protected_without_scope', nil, 'HTTP_AUTHORIZATION' => "Bearer #{unscoped_token.token}" }.to raise_exception(WineBouncer::Errors::OAuthForbiddenError)
    end
  end

  context 'oauth2_dsl' do
    it 'allows to call an protected endpoint without scopes' do
      get '/protected_api/oauth2_dsl', nil, 'HTTP_AUTHORIZATION' => "Bearer #{token.token}"

      expect(last_response.status).to eq(200)
      json = JSON.parse(last_response.body)
      expect(json).to have_key('hello')
      expect(json['hello']).to eq('oauth2_dsl')
    end

    it 'raises an error when an protected endpoint is called without token' do
      expect { get '/protected_api/oauth2_dsl' }.to raise_exception(WineBouncer::Errors::OAuthUnauthorizedError)
    end

    context 'without parameters' do
      it 'allows to call an endpoint with default scopes' do
        get '/protected_api/oauth2_protected_with_default_scopes', nil, 'HTTP_AUTHORIZATION' => "Bearer #{token.token}"
        expect(last_response.status).to eq(200)
        json = JSON.parse(last_response.body)
        expect(json).to have_key('hello')
        expect(json['hello']).to eq('default oauth2 dsl')
      end

      it 'raises an error when an protected endpoint without scopes is called without token ' do
        expect { get '/protected_api/oauth2_protected_with_default_scopes' }.to raise_exception(WineBouncer::Errors::OAuthUnauthorizedError)
      end

      it 'raises an error when token scopes are not default scopes ' do
        expect { get '/protected_api/oauth2_protected_with_default_scopes', nil, 'HTTP_AUTHORIZATION' => "Bearer #{custom_scope.token}" }.to raise_exception(WineBouncer::Errors::OAuthForbiddenError)
      end
    end

    context 'custom scopes' do
      it 'protects endpoints with custom scopes' do
        get '/protected_api/oauth2_dsl_custom_scope', nil, 'HTTP_AUTHORIZATION' => "Bearer #{custom_scope.token}"
        expect(last_response.status).to eq(200)
        json = JSON.parse(last_response.body)
        expect(json).to have_key('hello')
        expect(json['hello']).to eq('custom scope')
      end

      it 'raises an error when an protected endpoint without scopes is called without token ' do
        expect { get '/protected_api/oauth2_dsl_custom_scope' }.to raise_exception(WineBouncer::Errors::OAuthUnauthorizedError)
      end

      it 'raises an error when token scopes do not match' do
        expect { get '/protected_api/oauth2_dsl_custom_scope', nil, 'HTTP_AUTHORIZATION' => "Bearer #{token.token}" }.to raise_exception(WineBouncer::Errors::OAuthForbiddenError)
      end
    end

    context 'public endpoint' do
      it 'allows to call an unprotected endpoint without token' do
        get '/protected_api/unprotected_endpoint'
        expect(last_response.status).to eq(200)
        json = JSON.parse(last_response.body)
        expect(json).to have_key('hello')
        expect(json['hello']).to eq('public oauth2 dsl')
      end

      it 'allows requests with tokens to public endpoints with tokens' do
        expect { get '/protected_api/oauth2_protected_with_default_scopes', nil, 'HTTP_AUTHORIZATION' => "Bearer #{token.token}" }.not_to raise_error
      end
    end
  end

  context 'not_described_world' do
    it 'authentication is required for a non described endpoint' do
      get '/protected_api/not_described_world', nil, 'HTTP_AUTHORIZATION' => "Bearer #{token.token}"
      expect(last_response.status).to eq(200)
      json = JSON.parse(last_response.body)
      expect(json).to have_key('hello')
      expect(json['hello']).to eq('non described world')
    end

    it 'raises an error when an protected endpoint without scopes is called without token ' do
      expect { get '/protected_api/not_described_world' }.to raise_exception(WineBouncer::Errors::OAuthUnauthorizedError)
    end
  end

  context 'resource_owner' do
    it 'is available in the endpoint' do
      get '/protected_api/protected_user', nil, 'HTTP_AUTHORIZATION' => "Bearer #{token.token}"

      expect(last_response.status).to eq(200)
      json = JSON.parse(last_response.body)

      expect(json).to have_key('hello')
      expect(json['hello']).to eq(user.name)
    end
  end
end

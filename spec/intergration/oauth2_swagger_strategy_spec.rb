require 'rails_helper'
require 'json'

describe Api::MountedSwaggerApiUnderTest, type: :api do
  let(:user) { FactoryGirl.create :user }
  let(:token) { FactoryGirl.create :clientless_access_token, resource_owner_id: user.id, scopes: 'public' }
  let(:unscoped_token) { FactoryGirl.create :clientless_access_token, resource_owner_id: user.id, scopes: '' }
  let(:custom_scope) { FactoryGirl.create :clientless_access_token, resource_owner_id: user.id, scopes: 'custom_scope' } #not a default scope

  before (:example) do
    WineBouncer.configure do |c|
      c.auth_strategy = :swagger

      c.define_resource_owner do
        User.find(doorkeeper_access_token.resource_owner_id) if doorkeeper_access_token
      end
    end
  end

  context 'tokens and scopes' do
    it 'gives access when the token and scope are correct' do
      get '/swagger_api/protected', nil, 'HTTP_AUTHORIZATION' => "Bearer #{token.token}"

      expect(last_response.status).to eq(200)
      json = JSON.parse(last_response.body)
      expect(json).to have_key('hello')
    end

    it 'raises an authentication error when the token is invalid' do
      expect { get '/swagger_api/protected', nil, 'HTTP_AUTHORIZATION' => "Bearer #{token.token}-invalid" }.to raise_exception(WineBouncer::Errors::OAuthUnauthorizedError)
    end

    it 'raises an oauth authentication error when no token is given' do
      expect { get '/swagger_api/protected' }.to raise_exception(WineBouncer::Errors::OAuthUnauthorizedError)
    end

    it 'raises an auth forbidden authentication error when the user scope is not correct' do
      expect { get '/swagger_api/protected_with_private_scope', nil, 'HTTP_AUTHORIZATION' => "Bearer #{token.token}" }.to raise_exception(WineBouncer::Errors::OAuthForbiddenError)
    end
  end

  context 'unprotected endpoint' do
    it 'allows to call an unprotected endpoint without token' do
      get '/swagger_api/unprotected'

      expect(last_response.status).to eq(200)
      json = JSON.parse(last_response.body)

      expect(json).to have_key('hello')
      expect(json['hello']).to eq('unprotected world')
    end

    it 'allows to call an unprotected endpoint with token' do
      get '/swagger_api/unprotected', nil, 'HTTP_AUTHORIZATION' => "Bearer #{token.token}"

      expect(last_response.status).to eq(200)
      json = JSON.parse(last_response.body)
      expect(json).to have_key('hello')
      expect(json['hello']).to eq('unprotected world')
    end
  end

  context 'protected_without_scopes' do
    it 'allows to call an protected endpoint without scopes' do
      get '/swagger_api/protected_without_scope', nil, 'HTTP_AUTHORIZATION' => "Bearer #{token.token}"

      expect(last_response.status).to eq(200)
      json = JSON.parse(last_response.body)
      expect(json).to have_key('hello')
      expect(json['hello']).to eq('protected unscoped world')
    end

    it 'raises an error when an protected endpoint without scopes is called without token ' do
      expect { get '/swagger_api/protected_without_scope' }.to raise_exception(WineBouncer::Errors::OAuthUnauthorizedError)
    end

    it 'raises an error because the user does not have the default scope' do
      expect { get '/swagger_api/protected_without_scope', nil, 'HTTP_AUTHORIZATION' => "Bearer #{unscoped_token.token}" }.to raise_exception(WineBouncer::Errors::OAuthForbiddenError)
    end
  end

  context 'oauth2 dsl' do
    it 'allows to call an protected endpoint without scopes' do
      get '/swagger_api/oauth2_dsl', nil, 'HTTP_AUTHORIZATION' => "Bearer #{token.token}"

      expect(last_response.status).to eq(200)
      json = JSON.parse(last_response.body)
      expect(json).to have_key('hello')
      expect(json['hello']).to eq('oauth2_dsl')
    end

    it 'raises an error when an protected endpoint without scopes is called without token ' do
      expect { get '/swagger_api/oauth2_dsl' }.to raise_exception(WineBouncer::Errors::OAuthUnauthorizedError)
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
        expect { get '/swagger_api/oauth2_dsl_default_scopes' }.to raise_exception(WineBouncer::Errors::OAuthUnauthorizedError)
      end

      it 'raises an error when token scopes are not default scopes ' do
        expect { get '/swagger_api/oauth2_dsl_default_scopes', nil, 'HTTP_AUTHORIZATION' => "Bearer #{custom_scope.token}" }.to raise_exception(WineBouncer::Errors::OAuthForbiddenError)
      end
    end

    context 'custom scopes' do
      it 'accepts tokens with default scopes' do
        get '/swagger_api/oauth2_dsl_custom_scopes', nil, 'HTTP_AUTHORIZATION' => "Bearer #{custom_scope.token}"
        expect(last_response.status).to eq(200)
        json = JSON.parse(last_response.body)
        expect(json).to have_key('hello')
        expect(json['hello']).to eq('oauth dsl custom scopes')
      end

      it 'raises an error when an protected endpoint without scopes is called without token ' do
        expect { get '/swagger_api/oauth2_dsl_custom_scopes' }.to raise_exception(WineBouncer::Errors::OAuthUnauthorizedError)
      end

      it 'raises an error when token scopes do not match' do
        expect { get '/swagger_api/oauth2_dsl_custom_scopes', nil, 'HTTP_AUTHORIZATION' => "Bearer #{token.token}" }.to raise_exception(WineBouncer::Errors::OAuthForbiddenError)
      end
    end
  end

  context 'not_described_world' do
    it 'allows to call an endpoint without description' do
      get '/swagger_api/not_described_world'
      expect(last_response.status).to eq(200)
      json = JSON.parse(last_response.body)
      expect(json).to have_key('hello')
      expect(json['hello']).to eq('non described world')
    end
  end

  context 'resource_owner' do
    it 'is available in the endpoint' do
      get '/swagger_api/protected_user', nil, 'HTTP_AUTHORIZATION' => "Bearer #{token.token}"

      expect(last_response.status).to eq(200)
      json = JSON.parse(last_response.body)

      expect(json).to have_key('hello')
      expect(json['hello']).to eq(user.name)
    end
  end
end

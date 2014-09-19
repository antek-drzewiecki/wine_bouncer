require 'spec_helper'
require 'wine_bouncer/auth_strategies/default'

describe ::WineBouncer::AuthStrategies::Default do
  subject(:klass) { ::WineBouncer::AuthStrategies::Default.new }

  let(:scopes) { [ 'public', 'private' ] }
  let(:scopes_hash) { { scopes: scopes } }
  let(:auth_context) { { auth: scopes_hash } }


  context 'endpoint_authorizations' do
    it 'returns the auth key of the authentication hash.' do
      expect(klass.send(:endpoint_authorizations, auth_context)).to eq(scopes_hash)
    end

    it 'returns nil when the authentication key has no hash key.' do
      invalid_hash = { some: scopes_hash }
      expect(klass.send(:endpoint_authorizations, invalid_hash ) ).to eq(nil)
    end
  end

  context 'has_authorizations?' do
    it 'returns true when the context has the auth key.' do
      expect(klass.send(:has_authorizations?, auth_context)).to eq(true)
    end

    it 'returns false when the context has no auth key.' do
      invalid_hash = { some: scopes_hash }
      expect(klass.send(:has_authorizations?, invalid_hash ) ).to eq(false)
    end
  end

  context 'endpoint_protected?' do
    it 'returns true when the context has the auth key.' do
      expect(klass.endpoint_protected?(auth_context)).to eq(true)
    end

    it 'returns false when the context has no auth key.' do
      invalid_hash = { some: scopes }
      expect(klass.endpoint_protected?( invalid_hash ) ).to eq(false)
    end
  end

  context 'has_auth_scopes?' do
    it 'returns true when the context has the auth key.' do
      expect(klass.has_auth_scopes?(auth_context)).to eq(true)
    end

    it 'returns false when the context has no auth key.' do
      invalid_hash = { some: scopes_hash }
      expect(klass.has_auth_scopes?(invalid_hash) ).to eq(false)
    end

    it 'returns false when the auth scopes contain a blank scope array' do
      blank_scopes = { auth: { scopes: [] } }
      expect(klass.has_auth_scopes?(blank_scopes) ).to eq(false)
    end
  end

  context 'auth_scopes' do
    it 'returns an array of scopes' do
      expect(klass.auth_scopes(auth_context)).to eq([:public, :private])
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'
require 'wine_bouncer/auth_strategies/swagger'

describe ::WineBouncer::AuthStrategies::Swagger do
  subject(:klass) { ::WineBouncer::AuthStrategies::Swagger.new }

  let(:scopes) { [{ scope: 'private', description: 'anything' },{ scope: 'public', description: 'anything' }] }
  let(:scopes_map) { { oauth2: scopes } }
  let(:auth_context) { { route_options: { authorizations: scopes_map } } }

  context 'endpoint_authorizations' do
    it 'returns the auth key of the authentication hash.' do
      context_double = double()
      allow(context_double).to receive(:options) { auth_context }
      klass.api_context = context_double
      expect(klass.send(:endpoint_authorizations)).to eq(scopes_map)
    end

    it 'returns nil when the authentication key has no hash key.' do
      context_double = double()
      allow(context_double).to receive(:options) { { route_options: { some: scopes_map } } }
      klass.api_context = context_double
      expect(klass.send(:endpoint_authorizations)).to eq(nil)
    end
  end

  context 'has_authorizations?' do
    it 'returns true when it has an authentication hash.' do
      context_double = double()
      allow(context_double).to receive(:options) { auth_context }
      klass.api_context = context_double
      expect(klass.send(:has_authorizations?)).to eq(true)
    end

    it 'returns false when there is no authentication key.' do
      context_double = double()
      allow(context_double).to receive(:options) { { route_options: { some: scopes_map } } }
      klass.api_context = context_double
      expect(klass.send(:has_authorizations?)).to eq(false)
    end
  end

  context 'authorization_type_oauth2' do
    it 'returns the scopes.' do
      context_double = double()
      allow(context_double).to receive(:options) { auth_context }
      klass.api_context = context_double
      expect(klass.send(:authorization_type_oauth2)).to eq(scopes)
    end

    it 'returns nil when there is no oauth2 key.' do
      context_double = double()
      allow(context_double).to receive(:options) { { route_options: { authorizations: { no_oauth: scopes } } } }
      klass.api_context = context_double
      expect(klass.send(:authorization_type_oauth2)).to eq(nil)
    end
  end

  context 'endpoint_protected?' do
    it 'returns true when the context has the auth key.' do
      context_double = double()
      allow(context_double).to receive(:options) { auth_context }
      klass.api_context = context_double
      expect(klass.endpoint_protected?).to eq(true)
    end

    it 'returns false when the context has no auth key.' do
      context_double = double()
      allow(context_double).to receive(:options) { { route_options: { some: scopes_map } } }
      klass.api_context = context_double
      expect(klass.endpoint_protected?).to eq(false)
    end
  end

  context 'has_auth_scopes?' do
    it 'returns true when the context has the auth key.' do
      context_double = double()
      allow(context_double).to receive(:options) { auth_context }
      klass.api_context = context_double
      expect(klass.has_auth_scopes?).to eq(true)
    end

    it 'returns false when the context has no authorizations key.' do
      context_double = double()
      allow(context_double).to receive(:options) { { route_options: { some: scopes_map } } }
      klass.api_context = context_double
      expect(klass.has_auth_scopes?).to eq(false)
    end

    it 'returns false when the context has no oauth2 key.' do
      context_double = double()
      allow(context_double).to receive(:options) { { route_options: { authorizations: { no_oauth: scopes } } } }
      klass.api_context = context_double
      expect(klass.has_auth_scopes?).to eq(false)
    end

    it 'returns false when the auth scopes contain a blank scope array' do
      context_double = double()
      allow(context_double).to receive(:options) { { route_options: { authorizations: { oauth2: [] } } } }
      klass.api_context = context_double
      expect(klass.has_auth_scopes?).to eq(false)
    end
  end

  context 'auth_scopes' do
    it 'returns an array of scopes' do
      context_double = double()
      allow(context_double).to receive(:options) { auth_context }
      klass.api_context = context_double
      expect(klass.auth_scopes).to eq([:private, :public])
    end
  end
end

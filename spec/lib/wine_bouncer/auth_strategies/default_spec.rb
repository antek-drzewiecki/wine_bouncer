# frozen_string_literal: true

require 'rails_helper'
require 'wine_bouncer/auth_strategies/default'

describe WineBouncer::AuthStrategies::Default do
  subject(:klass) { described_class.new }

  let(:scopes) { %w[public private] }
  let(:scopes_hash) { { scopes: } }
  let(:auth_context) { { route_options: { auth: scopes_hash } } }

  describe 'endpoint_authorizations' do
    it 'returns the auth key of the authentication hash.' do
      context_double = double
      allow(context_double).to receive(:options) { auth_context }
      klass.api_context = context_double
      expect(klass.send(:endpoint_authorizations)).to eq(scopes_hash)
    end

    it 'returns nil when the authentication key has no hash key.' do
      context_double = double
      allow(context_double).to receive(:options) { { route_options: { some: scopes_hash } } }
      klass.api_context = context_double
      expect(klass.send(:endpoint_authorizations)).to be_nil
    end
  end

  describe 'endpoint_protected?' do
    it 'returns true when the context has the auth key.' do
      context_double = double
      allow(context_double).to receive(:options) { auth_context }
      klass.api_context = context_double
      expect(klass.endpoint_protected?).to be(true)
    end

    it 'returns false when the context has no auth key.' do
      context_double = double
      allow(context_double).to receive(:options) { { route_options: { some: scopes_hash } } }
      klass.api_context = context_double
      expect(klass.endpoint_protected?).to be(false)
    end
  end

  describe 'has_auth_scopes?' do
    it 'returns true when the context has the auth key.' do
      context_double = double
      allow(context_double).to receive(:options) { auth_context }
      klass.api_context = context_double
      expect(klass.has_auth_scopes?).to be(true)
    end

    it 'returns false when the context has no auth key.' do
      context_double = double
      allow(context_double).to receive(:options) { { route_options: { some: scopes_hash } } }
      klass.api_context = context_double
      expect(klass.has_auth_scopes?).to be(false)
    end

    it 'returns false when the auth scopes contain a blank scope array' do
      context_double = double
      allow(context_double).to receive(:options).and_return({ route_options: { auth: { scopes: [] } } })
      klass.api_context = context_double
      expect(klass.has_auth_scopes?).to be(false)
    end
  end

  describe 'auth_scopes' do
    it 'returns an array of scopes' do
      context_double = double
      allow(context_double).to receive(:options) { auth_context }
      klass.api_context = context_double
      expect(klass.auth_scopes).to eq(%i[public private])
    end
  end
end

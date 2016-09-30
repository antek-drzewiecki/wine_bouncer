# frozen_string_literal: true

require 'rails_helper'
require 'wine_bouncer/auth_strategies/default'

describe ::WineBouncer::AuthStrategies::Default do
  subject(:klass) { ::WineBouncer::AuthStrategies::Default.new }

  let(:scopes) { %w(public private) }
  let(:scopes_hash) { { scopes: scopes } }
  let(:auth_context) { { route_options: { auth: scopes_hash } } }

  context 'endpoint_protected?' do
    it 'returns true when the context has the auth key.' do
      context_double = double()
      allow(context_double).to receive(:options) { auth_context }
      klass.api_context = context_double
      expect(klass.endpoint_protected?).to be_truthy
    end

    it 'returns false when the context has no auth key.' do
      context_double = double()
      allow(context_double).to receive(:options) { { route_options: { some: scopes_hash } } }
      klass.api_context = context_double
      expect(klass.endpoint_protected?).to be_falsey
    end
  end

  context 'auth_scopes' do
    it 'returns an array of scopes' do
      context_double = double()
      allow(context_double).to receive(:options) { auth_context }
      klass.api_context = context_double
      expect(klass.auth_scopes).to eq([:public, :private])
    end
  end
end

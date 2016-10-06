# frozen_string_literal: true

require 'rails_helper'
require 'wine_bouncer/auth_strategies/default'

RSpec.describe WineBouncer::AuthStrategies::Default do
  let(:scopes) { %w(public private) }
  let(:scopes_hash) { { scopes: scopes } }
  let(:auth_context) { { route_options: { auth: scopes_hash } } }

  let(:klass) { WineBouncer::OAuth2.clone }
  let(:strategy) { WineBouncer::AuthStrategies::Default.clone }
  let(:klass_with_strategy) { klass.include strategy }
  let(:middleware_object) { klass_with_strategy.new(scopes) }

  context 'endpoint_protected?' do
    it 'returns true when the context has the auth key.' do
      context_double = double()
      allow(context_double).to receive(:options) { auth_context }
      middleware_object.context = context_double
      expect(middleware_object.endpoint_protected?).to be_truthy
    end

    it 'returns false when the context has no auth key.' do
      context_double = double()
      allow(context_double).to receive(:options) { { route_options: { some: scopes_hash } } }
      middleware_object.context = context_double
      expect(middleware_object.endpoint_protected?).to be_falsey
    end
  end

  context 'auth_scopes' do
    it 'returns an array of scopes' do
      context_double = double()
      allow(context_double).to receive(:options) { auth_context }
      middleware_object.context = context_double
      expect(middleware_object.auth_scopes).to eq([:public, :private])
    end
  end
end

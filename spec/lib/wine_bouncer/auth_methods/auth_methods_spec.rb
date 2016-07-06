# frozen_string_literal: true

require 'rails_helper'

describe ::WineBouncer::AuthMethods do
  let(:tested_class) do
    Class.new do
      include ::WineBouncer::AuthMethods
    end.new
  end
  let(:user) { FactoryGirl.create(:user) }
  let(:token) { FactoryGirl.create :clientless_access_token, resource_owner_id: user.id, scopes: 'public' }

  context 'doorkeeper_access_token' do
    it 'sets and gets a token' do
      tested_class.doorkeeper_access_token = token
      expect(tested_class.doorkeeper_access_token).to eq(token)
    end
  end

  context 'has_resource_owner?' do
    it 'gives true when the token has an resource owner' do
      tested_class.doorkeeper_access_token = token

      expect(tested_class.has_resource_owner?).to be true
    end

    it 'gives false when the class an no token' do
      expect(tested_class.has_resource_owner?).to be false
    end

    it 'gives false when the token has no resource owner' do
      token.resource_owner_id = nil
      tested_class.doorkeeper_access_token = token

      expect(tested_class.has_resource_owner?).to be false
    end
  end

  context 'has_doorkeeper_token?' do
    it 'returns true when the class has a token' do
      tested_class.doorkeeper_access_token = token
      expect(tested_class.has_doorkeeper_token?).to be true
    end

    it 'returns false when the class has no token' do
      expect(tested_class.has_doorkeeper_token?).to be false
    end
  end

  context 'client_credential_token?' do
    it 'return true if the doorkeeper token is aquired through client_credential authentication' do
      token.resource_owner_id = nil
      tested_class.doorkeeper_access_token = token
      expect(tested_class.client_credential_token?).to be true
    end

    it 'return false if no token is set' do
      token.resource_owner_id = nil
      tested_class.doorkeeper_access_token
      expect(tested_class.client_credential_token?).to be false
    end

    it 'return false if the token has a resource_owner' do
      token.resource_owner_id = 2
      tested_class.doorkeeper_access_token = token
      expect(tested_class.client_credential_token?).to be false
    end
  end

  context 'protected_endpoint?' do
    it 'when set true it returns true' do
      tested_class.protected_endpoint = true
      expect(tested_class.protected_endpoint?).to be true
    end

    it 'when set false it returns false' do
      tested_class.protected_endpoint = false
      expect(tested_class.protected_endpoint?).to be false
    end

    it 'defaults returns false if not set' do
      expect(tested_class.protected_endpoint?).to be false
    end
  end

  context 'resource_owner' do
    it 'runs the configured block' do
      result = 'called block'
      foo = proc { result }

      WineBouncer.configure do |c|
        c.auth_strategy = :default
        c.define_resource_owner(&foo)
      end

      expect(tested_class.resource_owner).to be(result)
    end

    it 'raises an argument error when the block is not configured' do
      WineBouncer.configuration = WineBouncer::Configuration.new
      expect { tested_class.resource_owner }.to raise_error(WineBouncer::Errors::UnconfiguredError)
    end
  end
end

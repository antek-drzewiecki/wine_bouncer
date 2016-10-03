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

  context 'resource_owner' do
    it 'runs the configured block' do
      result = 'called block'
      foo = proc { result }

      WineBouncer.configure do |c|
        c.auth_strategy = :default
        c.define_resource_owner(&foo)
      end

      expect(WineBouncer.configuration.defined_resource_owner.call).to be(result)
    end

    it 'raises an argument error when there is no block in configuration' do
      WineBouncer.configuration = WineBouncer::Configuration.new
      expect { WineBouncer.configuration.define_resource_owner }.to raise_error(ArgumentError)
    end
  end
end

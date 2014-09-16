require 'spec_helper'

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
end

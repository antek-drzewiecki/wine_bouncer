module Api

  ###
  # Api under test, default doorkeeper scope is 'account'
  ##
  class MountedDefaultApiUnderTest < Grape::API
    desc 'Protected method with public', auth: [{ scope: 'public' }]
    get '/protected' do
      { hello: 'world' }
    end

    desc 'Protected method with private', auth: [{ scope: 'private' }]
    get '/protected_with_private_scope' do
      { hello: 'scoped world' }
    end

    desc 'Unprotected method'
    get '/unprotected' do
      { hello: 'unprotected world' }
    end

    desc 'Protected method with public that returns the user name', auth: [{ scope: 'public'}]
    get '/protected_user' do
      { hello: resource_owner.name }
    end

    desc 'This method uses Doorkeepers default scopes', auth: []
    get '/protected_without_scope' do
      { hello: 'protected unscoped world' }
    end
  end

  class DefaultApiUnderTest < Grape::API
    default_format :json
    format :json
    use ::WineBouncer::OAuth2
    mount MountedDefaultApiUnderTest
  end

end

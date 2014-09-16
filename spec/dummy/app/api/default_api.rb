module Api

  ###
  # Api under test, default doorkeeper scope is 'account'
  ##
  class MountedDefaultApiUnderTest < Grape::API
    desc 'Document root', authorizations: [{ scope: 'public' }]
    get '/protected' do
      { hello: 'world' }
    end
    desc 'Document root', authorizations: [{ scope: 'private' }]
    get '/protected_with_private_scope' do
      { hello: 'scoped world' }
    end
    get '/unprotected' do
      { hello: 'unprotected world' }
    end
    desc 'Document root', authorizations: [{ scope: 'public'}]
    get '/protected_user' do
      { hello: current_user.name }
    end
    desc 'Document root', authorizations: []
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

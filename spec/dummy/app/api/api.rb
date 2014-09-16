module Api

  ###
  # Api under test, default doorkeeper scope is 'account'
  ##
  class MountedApiUnderTest < Grape::API
    desc 'Document root', authorizations: { oauth2: [{ scope: 'public', description: 'anything' }] }
    get '/protected' do
      { hello: 'world' }
    end
    desc 'Document root', authorizations: { oauth2: [{ scope: 'private', description: 'anything' }] }
    get '/protected_with_private_scope' do
      { hello: 'scoped world' }
    end
    get '/unprotected' do
      { hello: 'unprotected world' }
    end
    desc 'Document root', authorizations: { oauth2: [{ scope: 'public', description: 'anything' }] }
    get '/protected_user' do
      { hello: current_user.name }
    end
    desc 'Document root', authorizations: { oauth2: [] }
    get '/protected_without_scope' do
      { hello: 'protected unscoped world' }
    end
  end

  class ApiUnderTest < Grape::API
    default_format :json
    format :json
    use ::WineBouncer::OAuth2
    mount MountedApiUnderTest
  end

end

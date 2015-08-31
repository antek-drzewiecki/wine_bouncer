Upgrading WineBouncer
=====================

## Upgrading to >= 0.5.0

WineBouncer's exceptions `OAuthUnauthorizedError` and `OAuthForbiddenError` now come with a
corresponding Doorkeeper's error response. You can access it via `response` method of the exception.
For backward compatible, you can still use `message` but the content will be provided by Doorkeeper
error response's description.

## Upgrading to >=  0.3.0

An new DSL has been introduced to WineBouncer. This DSL will become the preferred way to authorize your endpoints.
The authentication trough endpoint description will become deprecated in the future version.

The old way to authorize your endpoints:

```
  desc 'protected method with required public and private scope',
  auth: { scopes: ['public','private'] }
  get '/protected' do
     { hello: 'world' }
  end
```

You may now write:
```
  desc 'protected method with required public and private scope'
  oauth2 'public', 'private'
  get '/protected' do
     { hello: 'world' }
  end
```

And even remove the description.

Note this is the last version that will support Grape 0.8 and 0.9. Grape 0.10 will be the next minimum Grape version.

### Upgrading to >= 0.2.0

To use the `resource_owner` you now need to define how WineBouncer gets the resource owner. In most cases he needs to return the User that is logged in, but not in all cases.
You now additionally need to specify `define_resource_owner` in your configuration. Mostly this the following code will work:

``` ruby
WineBouncer.configure do |c|
  .......
  c.define_resource_owner do
    User.find(doorkeeper_access_token.resource_owner_id) if doorkeeper_access_token
  end
end
```

The required Grape version is now from 0.8 and above.

------
From version 0.1.0 upgrade instructions are given.

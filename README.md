# WineBouncer

[![Build Status](https://travis-ci.org/Antek-drzewiecki/wine_bouncer.svg?branch=master)](https://travis-ci.org/Antek-drzewiecki/wine_bouncer)
[![Code Climate](https://codeclimate.com/github/Antek-drzewiecki/wine_bouncer/badges/gpa.svg)](https://codeclimate.com/github/Antek-drzewiecki/wine_bouncer)
[![Gem Version](https://badge.fury.io/rb/wine_bouncer.svg)](http://badge.fury.io/rb/wine_bouncer)

Protect your precious Grape API with Doorkeeper. 
WineBouncer uses minimal modification,  to make the magic happen.

Table of Contents
=================
  * [Requirements](#requirements)
  * [Installation](#installation)
  * [Usage](#usage)
    * [Authentication strategies](#authentication-strategies)
      * [Default](#default)
      * [Swagger](#swagger)
    * [Token information](#token-information)
  * [Exceptions and Exception handling](#exceptions-and-exception-handling)
  * [Development](#development)
  * [Contributing](#contributing)


## Requirements
- Ruby >1.9.3
- Doorkeeper > 1.4.0
- Grape > 0.8.0

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'wine_bouncer'
```

And then execute:

```ruby
bundle
```    

## Usage
WineBouncer is a custom Grape Middleware used for Authentication and Authorization. We assume you have a Grape API mounted in your Rails application together with Doorkeeper.  

To get started with WineBouncer, create a rails initializer in your Rails app at `config/initializer/wine_bouncer.rb` with the following configuration.

``` ruby
WineBouncer.configure do |config|
    config.auth_strategy = :default
end
```

Then register WineBouncer as Grape middleware in your Grape API.

``` ruby
class Api < Grape::API
   default_format :json
   format :json
   use ::WineBouncer::OAuth2
   mount YourAwesomeApi
end
```

WineBouncer relies on Grape's endpoint method description to define if an endpoint method should be protected. 
It comes with authorization strategies that allow a custom format for your authorization definition. Pick an authentication strategy to get started.
Currently the following strategies are included:

### Authentication strategies

#### Default
The default strategy uses the `auth:` key in the description options hash to define API method authentication. It accepts an array of scopes for authorization.
WineBouncer uses the default Doorkeeper behaviour for scopes.

Example:

``` ruby
 class MyAwesomeAPI < Grape::API
    desc 'protected method with required public scope', 
    auth: [{ scope: 'public' }]
    get '/protected' do
       { hello: 'world' }
    end
    
    desc 'Unprotected method'
    get '/unprotected' do
      { hello: 'unprotected world' }
    end
    
    desc 'This method needs the public or private scope.',
    auth: [{ scope: 'public' }, { scope: 'private' }]
    get '/method' do
      { hello: 'public or private user.' }
    end
    
    desc 'This method uses Doorkeepers default scopes.', 
    auth: []
    get '/protected_with_default_scope' do
       { hello: 'protected unscoped world' }
    end
 end
 
 class Api < Grape::API
    default_format :json
    format :json
    use ::WineBouncer::OAuth2
    mount MyAwesomeAPI
    add_swagger_documentation
 end
```


#### Swagger

WineBouncer comes with a strategy that can be perfectly used with [grape-swagger](https://github.com/tim-vandecasteele/grape-swagger) with a syntax compliant with the [swagger spec](https://github.com/wordnik/swagger-spec/).
This might be one of the simplest methods to protect your API and serve it with documentation. You can use [swagger-ui](https://github.com/wordnik/swagger-ui) to view your documentation.
 
To get started ensure you also have included the `grape-swagger` gem in your gemfile.

Run `bundle` to install the missing gems.

Create a rails initializer in your Rails app at `config/initializer/wine_bouncer.rb` with the following configuration.

``` ruby
    WineBouncer.configure do |config|
        config.auth_strategy = :swagger
    end
```

Then you can start documenting and protecting your API like the example below.

``` ruby

 class MyAwesomeAPI < Grape::API
    desc 'protected method with required public scope', 
    authorizations: { oauth2: [{ scope: 'public' }] }
    get '/protected' do
       { hello: 'world' }
    end
    
    desc 'Unprotected method'
    get '/unprotected' do
      { hello: 'unprotected world' }
    end
    
    desc 'This method uses Doorkeepers default scopes.', 
    authorizations: { oauth2: [] }
    get '/protected_with_default_scope' do
       { hello: 'protected unscoped world' }
    end
    
    desc 'It even works with other options!', 
    authorizations: { oauth2: [] },
    :entity => Api::Entities::Installation,
    http_codes: [  
        [200, 'OK', Api::Entities::Response],
        [401, 'Unauthorized', Api::Entities::Error],
        [403, 'Forbidden', Api::Entities::Error]
    ],     
    :notes => <<-NOTE
    
    Marked down notes!
    
    NOTE
    get '/extended_api' do
       { hello: 'Awesome world' }
    end
 end
 
 class Api < Grape::API
    default_format :json
    format :json
    use ::WineBouncer::OAuth2
    mount MyAwesomeAPI
    add_swagger_documentation
 end
```

The Swagger strategy uses the `authorizations: { oauth2: [] }` in the method description syntax to define API method authentication and authorization.
It defaults assumes when no description is given that no authorization should be used like the `/unprotected` method.
When the authentication syntax is mentioned in the method description, the method will be protected.
You can use the default scopes of Doorkeeper by just adding `authorizations: { oauth2: [] }` or state your own scopes with `authorizations: { oauth2: [ { scope: 'scope1' }, { scope: 'scope2' }, ... ] }`.

### Token information

WineBouncer comes with free extras! Methods for `resource_owner` and `doorkeeper_access_token` get included in your endpoints. You can use them to get the current resource owner, and the access_token object of doorkeeper. 

## Exceptions and Exception handling

This gem raises the following exceptions which can be handled in your Grape API, see [Grape documentation](https://github.com/intridea/grape#exception-handling).

* `WineBouncer::Errors::OAuthUnauthorizedError`
   when the request is unauthorized.
* `WineBouncer::Errors::OAuthForbiddenError` 
   when the token is found but scopes do not match.

## Development

Todo: write instructions..

## Contributing

1. Fork it ( https://github.com/[my-github-username]/wine_bouncer/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Write Tests and/or Code. Code without tests will not be accepted. 
4. Write documentation.
5. Commit your changes (`git commit -am 'Add some feature'`)
6. Push to the branch (`git push origin my-new-feature`)
7. Create a new Pull Request

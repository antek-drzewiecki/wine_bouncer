# WineBouncer

[![Build Status](https://travis-ci.org/antek-drzewiecki/wine_bouncer.svg?branch=master)](https://travis-ci.org/antek-drzewiecki/wine_bouncer)
[![Code Climate](https://codeclimate.com/github/antek-drzewiecki/wine_bouncer/badges/gpa.svg)](https://codeclimate.com/github/antek-drzewiecki/wine_bouncer)
[![Gem Version](https://badge.fury.io/rb/wine_bouncer.svg)](http://badge.fury.io/rb/wine_bouncer)
[![Documentation](https://inch-ci.org/github/antek-drzewiecki/wine_bouncer.svg)](https://inch-ci.org/github/antek-drzewiecki/wine_bouncer)

Protect your precious Grape API with Doorkeeper.
WineBouncer uses minimal modification, to make the magic happen.

Table of Contents
=================
  * [Requirements](#requirements)
  * [Installation](#installation)
  * [Upgrading](#upgrading)
  * [Usage](#usage)
    * [Easy DSL](#easy-dsl)
    * [Authentication strategies](#authentication-strategies)
      * [Default](#default)
      * [Swagger](#swagger)
      * [Protected](#protected)
    * [Token information](#token-information)
    * [Disable WineBouncer](#disable-winebouncer)
  * [Exceptions and Exception handling](#exceptions-and-exception-handling)
  * [Example Application](#example-application)
  * [Development](#development)
  * [Contributing](#contributing)


## Requirements
- Ruby > 2.0
- Doorkeeper > 1.4.0 and < 4.0
- Grape > 0.10 and < 1.0
Please submit pull requests and Travis env bumps for newer dependency versions.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'wine_bouncer', '~> 0.5.0'
```

And then execute:

```ruby
bundle
```

## Upgrading
When upgrading from a previous version, see [UPGRADING](UPGRADING.md). You might also be interested at the [CHANGELOG](CHANGELOG.md).


## Usage
WineBouncer is a custom Grape Middleware used for Authentication and Authorization. We assume you have a Grape API mounted in your Rails application together with Doorkeeper.

To get started with WineBouncer, run the configuration initializer:

```shell
$ rails g wine_bouncer:initializer
```


This creates a rails initializer in your Rails app at `config/initializers/wine_bouncer.rb` with the following configuration:

``` ruby
WineBouncer.configure do |config|
  config.auth_strategy = :default

  config.define_resource_owner do
    User.find(doorkeeper_access_token.resource_owner_id) if doorkeeper_access_token
  end
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

### Easy DSL

WineBouncer comes with an easy DSL and relies on Grape's DSL extentions to define if an endpoint method should be protected.
You can protect an endpoint by calling `oauth2` method with optional scopes in front of the endpoint definition.

``` ruby
 class MyAwesomeAPI < Grape::API
    desc 'protected method with required public scope'
    oauth2 'public'
    get '/protected' do
       { hello: 'world' }
    end

    oauth2 'public'
    get '/with_no_description' do
       { hello: 'undescribed world' }
    end

    desc 'Unprotected method'
    get '/unprotected' do
      { hello: 'unprotected world' }
    end

    desc 'This method needs the public or private scope.'
    oauth2 'public', 'write'
    get '/method' do
      { hello: 'public or private user.' }
    end

    desc 'This method uses Doorkeepers default scopes.',
    oauth2
    get '/protected_with_default_scope' do
       { hello: 'protected unscoped world' }
    end
 end

 class Api < Grape::API
    default_format :json
    format :json
    use ::WineBouncer::OAuth2
    mount MyAwesomeAPI
 end
```

### Authentication strategies

Behaviour of the authentication can be customized by selecting an authentication strategy. The following authentication strategies are provided in the gem.

#### Default
The default strategy only authenticates endpoints which are annotated by the `oauth2` method. Un-annotated endpoints still can be accessed without authentication.

#### Swagger

WineBouncer comes with a strategy that can be perfectly used with [grape-swagger](https://github.com/tim-vandecasteele/grape-swagger) with a syntax compliant with the [swagger spec](https://github.com/wordnik/swagger-spec/).
This might be one of the simplest methods to protect your API and serve it with documentation. You can use [swagger-ui](https://github.com/wordnik/swagger-ui) to view your documentation.

To get started ensure you also have included the `grape-swagger` gem in your gemfile.

Run `bundle` to install the missing gems.

Create a rails initializer in your Rails app at `config/initializers/wine_bouncer.rb` with the following configuration.

``` ruby
WineBouncer.configure do |config|
    config.auth_strategy = :swagger

    config.define_resource_owner do
            User.find(doorkeeper_access_token.resource_owner_id) if doorkeeper_access_token
    end
end
```

Then you can start protecting your API like the example below.

``` ruby
desc 'This method needs the public or private scope.',
  success: Api::Entities::Response,
  failure: [
      [401, 'Unauthorized', Api::Entities::Error],
      [403, 'Forbidden', Api::Entities::Error]
  ],
  notes: <<-NOTE
  Marked down notes!
  NOTE
oauth2 'public', 'write'
get '/method' do
  { hello: 'public or private user.' }
end
```

The Swagger strategy uses scopes and injects them in the authorizations description for external application to be read.

#### Protected

The protected strategy is very similar to the default strategy except any public endpoint must explicitly set. To make an end point public, use `oauth2 false`.
If the authorization method is not set, the end point is assumed to be __protected with Doorkeeper's default scopes__ (which is the same as `oauth2 nil `.)
To protect your endpoint with other scopes append the following method `oauth2 'first scope', 'second scope'`.


### Token information

WineBouncer comes with free extras! Methods for `resource_owner` and `doorkeeper_access_token` get included in your endpoints. You can use them to get the current resource owner, and the access_token object of doorkeeper.

### Disable WineBouncer

If you want to disable WineBouncer conditionally - e.g. in specs - you can add a block to the WineBouncer configuration. When this block evaluates to true, any request will be unprotected. For example:
```{ruby}
WineBouncer.configure do |config|
  config.disable do
    Rails.env.test?
  end
end
```

The block is newly evaluated for every request, so you could in principle have something like:
```{ruby}
config.disable do
  [true, false].sample
end
```

You probably shouldn't, though.

## Exceptions and Exception handling

This gem raises the following exceptions which can be handled in your Grape API, see [Grape documentation](https://github.com/intridea/grape#exception-handling).

* `WineBouncer::Errors::OAuthUnauthorizedError`
   when the request is unauthorized.
* `WineBouncer::Errors::OAuthForbiddenError`
   when the token is found but scopes do not match.

Detailed doorkeeper error response can be found in the error's `response` attribute. You could use
it to compose the actual HTTP response to API users.

## Example/Template Application

A full working sample app (or starter template) can be found at [grape-doorkeeper on github](https://github.com/sethherr/grape-doorkeeper). It has one click deploy to Heroku and [a live example](https://grape-doorkeeper.herokuapp.com/).

## Development

Since we want the gem tested against several rails versions we use the same way to prepare our development environment as Doorkeeper.

To install the development environment for rails 3.2.18, you can also specify a different rails version to test against.

`rails=3.2.18 bundle install`

To run the specs.

`rails=3.2.18 bundle exec rake`

## Contributing

For contributing to the gem see [CONTRIBUTING](CONTRIBUTING.md).

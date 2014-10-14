Upgrading WineBouncer
=====================


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
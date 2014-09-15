Rails.application.routes.draw do
  use_doorkeeper
  mount Api::ApiUnderTest => '/api'
end

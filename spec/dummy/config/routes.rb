Rails.application.routes.draw do
  use_doorkeeper
  mount Api::DefaultApiUnderTest => '/default_api'
  mount Api::SwaggerApiUnderTest => '/swagger_api'
end

Rails.application.routes.draw do
  use_doorkeeper
  mount Api::DefaultApiUnderTest => '/default_api'
  mount Api::SwaggerApiUnderTest => '/swagger_api'
  mount Api::ProtectedApiUnderTest => '/protected_api'
  mount Api::PreGrape10::DefaultApiUnderTest => '/pre_grape_10/default_api'
  mount Api::PreGrape10::SwaggerApiUnderTest => '/pre_grape_10/swagger_api'
  mount Api::PreGrape10::ProtectedApiUnderTest => '/pre_grape_10/protected_api'
end

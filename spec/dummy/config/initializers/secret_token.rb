# frozen_string_literal: true
if ENV['rails'][0].to_i > 4 && ENV['rails'][2].to_i >= 1
  Dummy::Application.config.secret_key_base = '23d9b4867e1370428ac81119ec43914b117ef4d95e8cb563c7813b22e1ac260688d0b11958eaae30f587712ac75ab852c76b91594e9f8a851fa5cd53ef2088a4'
else
  Dummy::Application.config.secret_token = 'c65fd1ffec8275651d1fd06ec3a4914ba644bbeb87729594a3b35fb4b7ad4cccd298d77baf63f7a6513d437e5b95eef9637f9c37a9691c3ed41143d8b5f9a5ef'
end

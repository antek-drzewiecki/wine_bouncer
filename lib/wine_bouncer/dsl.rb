module WineBouncer
  module DSL
    def authenticate(options={})
      route_setting :authenticate, options
      #descr = route_setting :description
      #descr.merge! authorizations: options
      #route_setting :description, descr
    end

    Grape::API.extend self if WineBouncer.post_0_9_0_grape?
  end
end

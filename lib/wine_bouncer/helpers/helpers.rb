# frozen_string_literal: true

module WineBouncer
  module Helpers
    def self.object_attr_accessor(obj, attr_name)
      obj.send(:define_singleton_method, "#{attr_name}=".to_sym) do |value|
        instance_variable_set("@" + attr_name.to_s, value)
      end

      obj.send(:define_singleton_method, attr_name.to_sym) do
        instance_variable_get("@" + attr_name.to_s)
      end
    end
  end
end

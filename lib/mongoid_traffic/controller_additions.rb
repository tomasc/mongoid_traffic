module MongoidTraffic
  module ControllerAdditions

    module ClassMethods
    end

    def self.included base
      base.extend ClassMethods
      # base.helper_method :my_method if base.respond_to? :my_method
    end

  end
end

if defined? ActionController::Base
  ActionController::Base.class_eval do
    include MongoidTraffic::ControllerAdditions
  end
end
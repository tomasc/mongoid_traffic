module MongoidTraffic
  module ControllerAdditions

    module ClassMethods
      def log_traffic
      end
    end

    def self.included base
      base.extend ClassMethods
      base.helper_method :log_traffic if base.respond_to? :log_traffic
    end

  end
end

if defined? ActionController::Base
  ActionController::Base.class_eval do
    include MongoidTraffic::ControllerAdditions
  end
end
module MongoidTraffic
  module ControllerAdditions
    def log_traffic(log_cls, scope: nil)
      MongoidTraffic::Logger.log(
        log_cls,
        ip_address: request.remote_ip,
        referer: request.headers['Referer'],
        unique_id: request.session_options[:id], # FIXME: not sure about this
        user_agent: request.headers['User-Agent']
      )
    end

    def log_scoped_traffic(_log_cls, scope: nil)
      log_traffic(scope: (scope || request.fullpath.split('?').first))
    end

    # ---------------------------------------------------------------------

    def self.included(base)
      base.extend ClassMethods
      base.helper_method :log_traffic
      base.helper_method :log_scoped_traffic
    end
  end
end

if defined? ActionController::Base
  ActionController::Base.class_eval do
    include MongoidTraffic::ControllerAdditions
  end
end

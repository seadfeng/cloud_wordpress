module Wordpress
    module Routeable
        extend ActiveSupport::Concern
    
        included do
            include Rails.application.routes.url_helpers
        end

        # protected
    
        # def default_url_options
        #     Rails.application.config.action_mailer.default_url_options
        # end
    end
end
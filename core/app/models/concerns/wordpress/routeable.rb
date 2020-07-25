module Wordpress
    module Routeable
        extend ActiveSupport::Concern
    
        included do
            include Wordpress::Core::Engine.routes.url_helpers
        end

        protected
    
        def default_url_options
            Rails.application.routes.default_url_options || {}
        end
    end
end
module Wordpress
    class Cloudflare < Wordpress::Base
        module Preference
            extend ActiveSupport::Concern
            included do
                # preference :reviews_per_page, :integer, default: 12
                 
            end
        end
    end
end

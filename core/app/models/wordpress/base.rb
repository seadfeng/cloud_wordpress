module Wordpress 
    class Base < ApplicationRecord
        include Wordpress::Preferences::Preferable
        serialize :preferences, Hash
     
        after_initialize do
            if has_attribute?(:preferences) && !preferences.nil?
                self.preferences = default_preferences.merge(preferences)
            end
        end 
    
        def self.belongs_to_required_by_default
            false
        end
    
        def self.wordpress_base_scopes
            where(nil)
        end
    end
end
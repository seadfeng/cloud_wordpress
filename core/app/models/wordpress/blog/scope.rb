module Wordpress
    class Blog < Wordpress::Base
        module Scope
            extend ActiveSupport::Concern
            included do
                scope :by_states, lambda { |status| where( "#{Blog.table_name}.state": status)  unless status.blank? }
                scope :processing, -> { by_states("processing") } 
                scope :pending, -> { by_states("pending") }  
                scope :installed, -> { by_states("installed") }  
                scope :published, -> { by_states("published") }  
                scope :done, -> { by_states("done") }  
                
                scope :ssl_on,  -> { where("#{Blog.quoted_table_name}.use_ssl = ?", 1 ) }
                scope :ssl_off,  -> { where("#{Blog.quoted_table_name}.use_ssl = ?", 0 ) }   
                scope :published_today ,  -> { where("#{Blog.quoted_table_name}.published_at >= ?", Date.today ) } 
                scope :published_month ,   -> { where("#{Blog.quoted_table_name}.published_at >= ?", Date.today - 30 ) } 
                scope :cname_null,  -> { where("#{Blog.quoted_table_name}.cname is NOT NULL" ) } 
            end
        end
    end
end
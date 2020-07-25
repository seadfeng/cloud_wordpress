module Wordpress
  class Cloudflare < Wordpress::Base
    include Wordpress::Cloudflare::Preference
    include Validates
    acts_as_paranoid
    
    
    has_many :blogs

    scope :active, ->{ where("#{Cloudflare.quoted_table_name}.remaining > 0")}
    after_commit :clear_cache 

    with_options presence: true do 
      validates_uniqueness_of :api_user, case_sensitive: true, allow_blank: false     
      validates :api_user,  :api_token, :name , :domain
      validates :domain, domain: true 
    end  

    def self.cloudflare_cache(cloudflare_id = nil)
      return nil if cloudflare_id.nil?
      Rails.cache.fetch("cloudflare_key_#{cloudflare_id}") do
        self
      end
    end 

    def clear_cache
      Rails.cache.delete( "cloudflare_key_#{self.id}" ) 
    end


  end
end

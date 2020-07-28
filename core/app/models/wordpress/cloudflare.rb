module Wordpress
  class Cloudflare < Wordpress::Base
    include Wordpress::Cloudflare::Preference
    include Validates
    acts_as_paranoid
    
    
    has_many :blogs

    scope :active, ->{ where("#{Cloudflare.quoted_table_name}.remaining > 0")}
    after_commit :clear_cache 

    with_options presence: true do 
      validates_uniqueness_of :api_user, case_sensitive: true, allow_blank: false, scope: :domain           
      validates :api_user,  :api_token, :name , :domain
      validates :domain, domain: true 
    end  

    after_create :rsync_user_id 

    def rsync_user_id 
      cloudflare_api = Wordpress::Core::Helpers::CloudflareApi.new(self)  
      update_attribute(:user_id, cloudflare_api.get_user_id) if cloudflare_api.get_user_id
    end

    def self.cloudflare_cache(cloudflare_id)
      return nil if cloudflare_id.nil?
      Rails.cache.fetch("cloudflare_key_#{cloudflare_id}") do
        Cloudflare.find(cloudflare_id)
      end 
    end 

    def clear_cache
      Rails.cache.delete( "cloudflare_key_#{self.id}" ) 
    end


  end
end

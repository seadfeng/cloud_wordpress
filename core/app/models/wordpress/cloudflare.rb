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
    before_validation :check_domain, if: :domain_changed? , on: :update

    after_create :rsync_user_id 
    after_create :rsync_account_id 
    after_create :rsync_zone_id 

    def rsynced?
      user_id && zone_id && account_id
    end

    def rsync_user_id 
      cloudflare_api = Wordpress::Core::Helpers::CloudflareApi.new(self)  
      get_user_id = cloudflare_api.get_user_id
      update_attribute(:user_id, get_user_id) if get_user_id
    end

    def rsync_account_id 
      cloudflare_api = Wordpress::Core::Helpers::CloudflareApi.new(self)  
      get_account_id = cloudflare_api.get_account_id
      update_attribute(:account_id, get_account_id) if get_account_id
    end

    def rsync_zone_id
      cloudflare_api = Wordpress::Core::Helpers::CloudflareApi.new(self)  
      rsync_zone_id = cloudflare_api.find_or_create_zone(self.domain, self.user_id )
      update_attribute(:zone_id, rsync_zone_id) if rsync_zone_id
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

    private

    def check_domain
      errors.add(:domain, :cannot_change_if_has_blogs) if blogs.any?
    end


  end
end

module Wordpress
  class Domain < Wordpress::Base 
    include Validates
    acts_as_paranoid 
    has_many :blogs

    with_options presence: true do 
      validates_uniqueness_of :name, case_sensitive: true, allow_blank: false     
      validates  :name  
    end

    validates  :name, domain: true

    scope :active, ->{ joins(:blogs)  } 
    scope :cloudflare, ->{  where("#{Domain.quoted_table_name}.zone_id is not null")  } 
    scope :unuse_cloudflare, ->{  where("#{Domain.quoted_table_name}.zone_id is null")  } 
    scope :not_use, -> {  where("#{Domain.quoted_table_name}.id not in (?)",  active.ids)  }  

    after_commit :clear_cache 


    def self.cache_by_name(domain) 
      find_domain = Rails.cache.fetch("domain_key_#{domain}") do
        Domain.find_by_name(domain)
      end

      if find_domain.blank?
        Rails.cache.delete( "domain_key_#{domain}" ) 
      else
        find_domain
      end
    end 


    def blog_cache_by_subname(subdomain)
      cnames = [] 

      if subdomain.blank?
        cnames.push(nil) 
        cnames.push('') 
        cnames.push('@') 
      else
        cnames.push(subdomain) 
      end  

      find_blog = Rails.cache.fetch("blog_key_#{self.name}_#{subdomain}") do
        find_blogs = blogs.where(cname: cnames )
        find_blogs.last if find_blogs.any? 
      end

      if find_blog.blank?
        Rails.cache.delete( "blog_key_#{self.name}_#{subdomain}" ) 
      else
        find_blog
      end
    end

    def clear_cache
      Rails.cache.delete( "domain_key_#{self.name}" ) 
    end 

    def rsync_cloudflare_zone
      # Wordpress::DomainJob.perform_later(self, { action: "create_zone" } )
      Wordpress::DomainJob.perform_later(self, { action: "find_or_create_zone" } )
      # Wordpress::DomainJob.perform_later(self, { action: "find_or_create_zone" } )
    end
    
  end
end

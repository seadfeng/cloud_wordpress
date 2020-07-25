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
    scope :not_use, -> {  where("#{Domain.quoted_table_name}.id not in (?)",  active.ids)  }  

    after_commit :clear_cache 


    def self.domain_cache(domain)
      find_domain = Domain.find_by_name(domain)
      return nil if find_domain.blank?
      Rails.cache.fetch("domain_key_#{find_domain.id}") do
        find_domain
      end
    end 


    def blog_cache(subdomain)
      cnames = []
      find_blog = nil
      if subdomain.blank?
        cnames.push(nil) 
        cnames.push('') 
        cnames.push('@') 
      else
        cnames.push(subdomain) 
      end 
      find_blogs = blogs.where(cname: cnames )
      find_blog = find_blogs.last if find_blogs.any? 
      return nil if find_blog.blank?
      Rails.cache.fetch("blog_key_#{find_blog.id}") do
        find_blog
      end
    end

    def clear_cache
      Rails.cache.delete( "domain_key_#{self.id}" ) 
    end
    
  end
end

module Wordpress
  class Blog < Wordpress::Base
    include Wordpress::Blog::StateMachine 
    include Wordpress::Blog::Scope
    acts_as_paranoid
    include Wordpress::NumberGenerator.new(prefix: 'w')
    belongs_to :admin_user
    belongs_to :locale
    belongs_to :cloudflare
    belongs_to :domain
    belongs_to :server

    has_many :templates, through: :locale

    with_options presence: true do 
      validates_uniqueness_of :domain, case_sensitive: true, allow_blank: true, scope: :cname     
      validates :cloudflare,  :server , :locale , :admin_user
    end  

    before_validation :check_server_and_cloudflare

    before_validation :set_wordpress_user_and_password
    after_create :set_mysql_user_and_password

    def mysql_db
      self.mysql_user
    end

    def cloudflare_domain 
      "#{number}.#{cloudflare.domain}"
    end

    def cloudflare_origin 
      "https://#{cloudflare_domain}/"
    end 
    
    def online_origin
      proto = "http://"
      proto = "https://" if use_ssl
      if domain 
        if cname == "@" || cname.blank?
          "#{proto}#{domain.name}/"
        else
          "#{proto}#{cname}.#{domain.name}/"
        end 
      else
        nil
      end
    end

    def set_wordpress_user_and_password
      self.user = "admin"
      self.password = random_password
    end

    def set_mysql_user_and_password 
      update_attribute(:mysql_user, "wp_user_#{self.id}")
      update_attribute(:mysql_password, random_password)
    end

    private

    def check_server_and_cloudflare
      if self.server_id.blank? 
        self.server_id = Server.active&.first&.id
      end
      if self.cloudflare_id.blank?  
        self.cloudflare_id = Cloudflare.active&.first&.id
      end
    end 

    def random_password
      random = SecureRandom.urlsafe_base64(nil, false) 
      "!0O#{random}"
    end

    
  end
end

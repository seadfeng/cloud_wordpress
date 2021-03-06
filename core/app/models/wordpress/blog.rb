module Wordpress
  class Blog < Wordpress::Base
    include Wordpress::Blog::StateMachine 
    include Wordpress::Blog::Scope
    include Wordpress::Blog::MysqlConnect
    include Wordpress::Blog::WpConfig
    
    acts_as_paranoid
    include Wordpress::NumberGenerator.new(prefix: 'w')
    belongs_to :admin_user
    belongs_to :locale
    belongs_to :cloudflare
    belongs_to :domain
    belongs_to :server

    has_many :templates, through: :locale
    has_many :monitors 

    MONITOR_JOBS = %W( Wordpress::BlogCheckOnlineJob )

    with_options presence: true do 
      validates_uniqueness_of :domain, allow_blank: true, scope: :cname     
      validates :cloudflare,  :server , :locale , :admin_user
    end  

    before_validation :check_server_and_cloudflare
    before_validation :check_cname

    before_validation :set_wordpress_user_and_password, on: :create
    after_create :set_mysql_user_and_password 
    before_destroy :can_destroy?  

    attr_accessor :migration

    after_commit :clear_cache 

    def cloudflare?
      domain.cloudflare?  if domain
    end

    def check_online_job_class_name
      "Wordpress::BlogCheckOnlineJob"
    end

    def check_cname
      self.cname = "@" if cname.blank?
    end

    def migration
      ''
    end

    def migration=(data)
      return nil unless data.present?
    end

    def set_dns 
      rootdomain = cloudflare.domain
      raise I18n.t('activerecord.errors.models.wordpress/cloudflare.attributes.zone_id.cannot_set_dns_if_zone_id_blank', domain: rootdomain, default: "先获取Cloudflare \"%{domain}\" Zone Id信息，确保域名有解析权限") if cloudflare.zone_id.blank?
      cloudflare_api = Wordpress::Core::Helpers::CloudflareApi.new(cloudflare) 
      proxied = true
      update_attribute(:dns_status, 1) if cloudflare_api.create_or_update_dns_cname( cloudflare_domain, server.cname, proxied )  
    end

    def set_online_dns 
      if Wordpress::Config.cfp_enable && domain && domain.cloudflare?
        cfp_cloudflare = {
          api_user: Wordpress::Config.cfp_user,
          api_token: Wordpress::Config.cfp_token
        } 
        cloudflare_api = Wordpress::Core::Helpers::CloudflareApi.new(cfp_cloudflare) 
        proxied = true 
        cloudflare_api.set_zone_id(domain.zone_id)
        if cloudflare_api.create_or_update_dns_cname( origin, Wordpress::Config.cfp_all_in_one_cname, proxied ) 
          if (is_root?  || is_www?)
            cloudflare_api.create_or_update_dns_cname( other_origin, Wordpress::Config.cfp_all_in_one_cname, proxied )  
          end
          update_attribute(:dns_status, 1) 
        end
      end
    end

    def can_login?
      !self.pending? && !self.processing? 
    end

    def directory
       "#{Wordpress::Config.server_directory}/#{locale.code}/#{self.number}"
    end

    def display_name
      "ID ( #{id} ) - ##{number}"
    end

    def can_destroy? 
      errors.add(:state, :cannot_destroy_if_processing) if self.processing?
    end


    def master_template
      templates.first if templates.any?
    end

    def mysql_db
      self.mysql_user
    end

    def cloudflare_domain 
      "#{number}.#{cloudflare.domain}"
    end

    def cloudflare_origin 
      "https://#{cloudflare_domain}"
    end 

    def is_www? 
      self.cname == "www"  
    end

    def is_root? 
      self.cname == "@"  
    end

    def other_origin
      if origin
        if is_www?
          origin.gsub(/www./,'')
        elsif is_root?   
          "www.#{origin}"
        end
      end
    end

    def origin
      if domain 
        if is_root?  
          "#{domain.name}"
        else
          "#{cname}.#{domain.name}"
        end  
      end
    end

    def scheme 
      self.use_ssl ? "https://"  : "http://"
    end
    
    def online_origin 
      if domain  
        "#{scheme}#{origin}/"  
      end
    end

    def set_wordpress_user_and_password
      self.user = "admin" if user.blank?
      self.password = random_password if password.blank?
    end

    def set_mysql_user_and_password 
      update_attribute(:mysql_user, "wp_user_#{self.id}")
      update_attribute(:mysql_password, random_password)
    end
 
    def reset_password
      update_attribute(:password, random_password)
      Wordpress::BlogResetPasswordJob.perform_later(self)
    end 

    def create_online_virtual_host 
      apache_info ={
        directory:  self.directory, 
        server_name: self.origin,
        port: 80,  
      }
      apache = Wordpress::Core::Helpers::Apache.new(apache_info)
      create_virtual_host = apache.create_virtual_host 
      done = false
      Net::SSH.start( server.host,  server.host_user, :password => server.host_password, :port => server.host_port ) do |ssh|
        #create_virtual_host
        channel = ssh.open_channel do |ch|   
          ch.exec create_virtual_host do |ch, success| 
            if success 
              ch.on_data do |c, data|
                $stdout.print data  
                done = true if /Restart OK/.match(data)
              end 
            end
          end  
        end 
        channel.wait  
      end
      done 
    end
    
    def install_with_template(template = nil)
      template = master_template if template.nil? 
      if template
        self.install
        Wordpress::BlogInstallJob.perform_later(self, template ) 
      end
    end

    def clear_cache
      Rails.cache.delete( "blog_key_#{domain.name}_#{cname}" ) if domain
    end

    private

    def log_file 
      File.open('log/wordpress_blog.log', File::WRONLY | File::APPEND | File::CREAT)
    end

    def check_server_and_cloudflare
      if self.server_id.blank? 
        servers = Server.active
        if servers&.first
          self.server_id = Server.active.first.id
        else
          errors.add(:state, :cannot_create_if_none_server) 
        end
      end
      if self.cloudflare_id.blank? 
        cloudflares = Cloudflare.active
        if cloudflares&.first
          self.cloudflare_id = Cloudflare.active.first.id
        else
          errors.add(:state, :cannot_create_if_none_cloudflare) 
        end
      end 
    end 

    def random_password
      random = SecureRandom.urlsafe_base64(nil, false) 
      "i-#{random}"
    end 
  end
end

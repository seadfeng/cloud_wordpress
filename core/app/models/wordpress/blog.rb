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
      validates_uniqueness_of :domain, allow_blank: true, scope: :cname     
      validates :cloudflare,  :server , :locale , :admin_user
    end  

    before_validation :check_server_and_cloudflare

    before_validation :set_wordpress_user_and_password, on: :create
    after_create :set_mysql_user_and_password 
    before_destroy :can_destroy? 

    attr_accessor :migration

    after_commit :clear_cache 

    def migration
      ''
    end

    def migration=(data)
      return nil unless data.present?
    end

    def set_dns 
      rootdomain = cloudflare.domain
      cloudflare_api = Wordpress::Core::Helpers::CloudflareApi.new(cloudflare, rootdomain)
      proxied = true
      update_attribute(:dns_status, 1) if cloudflare_api.create_or_update_dns_cname( self.number, self.cloudflare_domain, proxied )  
    end

    def can_login?
      !self.pending? && !self.processing? 
    end

    def directory
       "#{Wordpress::Config.server_directory}/#{locale.code}/#{self.number}"
    end

    def reset_password
      update_attribute(:password, random_password)
      Wordpress::BlogResetPasswordJob.perform_later(self)
    end

    def display_name
      "ID ( #{id} ):  #{online_origin}"
    end

    def can_destroy? 
      errors.add(:state, :cannot_destroy_if_processing) if self.processing?
    end

    def install_with_template(template = nil)
      template = master_template if template.nil? 
      if template
        self.install
        Wordpress::BlogInstallJob.perform_later(self, template ) 
      end
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
      "https://#{cloudflare_domain}/"
    end 

    def origin
      if domain 
        if cname == "@" || cname.blank?
          "#{domain.name}"
        else
          "#{cname}.#{domain.name}"
        end 
      else
        nil
      end
    end
    
    def online_origin
      proto = "http://"
      proto = "https://" if use_ssl
      if domain  
        "#{proto}#{origin}/" 
      else
        nil
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

    def update_wp_config
      logger = Logger.new(log_file)
      begin
        Net::SSH.start( server.host,  server.host_user, :password => server.host_password) do |ssh| 
          logger.info("Blog Id:#{self.id} Start! ********************************/") 
          logger.info("SSH Connected: #{server.host}") 
          ssh_str = "
                      #{config_replace_db}
                      #{config_replace_user}
                      #{config_replace_db_password}
                      #{config_replace_db_host}
                      grep '#{self.mysql_password}' #{directory_wordpress_config}
                    "
          channel = ssh.open_channel do |ch|    
            puts ssh_str
            ch.exec ssh_str do |ch, success| 
              ch.on_data do |c, data|
                $stdout.print data  
                if /#{self.mysql_password}/.match(data)
                  logger.info("wp-config.php updated!") 
                end
              end 
            end
          end
          channel.wait
          logger.info("Blog Id:#{self.id} End! ********************************/") 
        end
      rescue Exception  => e 
        logger.error("Blog Id:#{self.id} ================")  
        logger.error(e.backtrace.join("\n"))
        nil
      end
      
    end

    def clear_cache
      Rails.cache.delete( "blog_key_#{self.id}" ) 
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

    def config_replace_db
      "sed -i \"/'DB_NAME'/ c define( 'DB_NAME', '#{mysql_db}' );\" #{directory_wordpress_config}"
    end

    def config_replace_user
      "sed -i \"/'DB_USER'/ c define( 'DB_USER', '#{self.mysql_user}' );\" #{directory_wordpress_config}"
    end

    def config_replace_db_password
      "sed -i \"/'DB_PASSWORD'/ c define( 'DB_PASSWORD', '#{self.mysql_password}' );\" #{directory_wordpress_config}"
    end

    def config_replace_db_host
      "sed -i \"/'DB_HOST'/ c define( 'DB_HOST', '#{server.mysql_host}' );\" #{directory_wordpress_config}"
    end

    def directory_wordpress
      "#{directory}/wordpress"
    end

    def directory_wordpress_config
      "#{directory_wordpress}/wp-config.php"
    end

    
  end
end

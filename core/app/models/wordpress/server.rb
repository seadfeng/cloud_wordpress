module Wordpress
  class Server < Wordpress::Base
    acts_as_paranoid
    include Validates
    belongs_to :cloudflare
    has_many :blogs 
    scope :active, ->{ left_joins(:blogs)
                       .select("COUNT( #{Blog.quoted_table_name}.id) AS blog_count, #{Server.quoted_table_name}.*").distinct
                       .group("#{Server.quoted_table_name}.id")
                       .where("#{Server.quoted_table_name}.host_status = 1 and #{Server.quoted_table_name}.mysql_status = 1")
                       .having("blog_count <  #{Server.quoted_table_name}.max_size")
                      }


    with_options presence: true do 
      validates_uniqueness_of :host, case_sensitive: true, allow_blank: false   
      # validates :domain, domain: true 
      validates :cloudflare,  :host, :host_user, :host_password, :mysql_host, :mysql_host_user, :mysql_password, :mysql_user
    end  

    before_validation :check_host,  if: :host_password_changed?
    before_validation :check_hosts, if: :host_changed? 
    before_validation :check_cloudflares, if: :cloudflare_id_changed? 

    def cname
     "server#{self.id}"
    end 

    def display_cname
      "#{cname}.#{cloudflare.domain}"
    end

    def check_cloudflares 
        errors.add(:cloudflare_id, :cannot_change_if_has_blogs) if blogs.any? 
    end

    def check_hosts 
        errors.add(:host, :cannot_change_if_has_blogs) if blogs.any? 
    end

    def check_host 
      begin  
        Net::SSH.start(self.host, self.host_user, :password => self.host_password, :port => self.host_port)   do |ssh|  
          self.host_status = 1 
          self.save
        end 
      rescue
        self.host_status = 0
        self.save
        nil
      end 
    end 

    def set_dns 
      rootdomain = cloudflare.domain
      cloudflare_api = Wordpress::Core::Helpers::CloudflareApi.new(cloudflare, rootdomain)
      update_attribute(:dns_status, 1)  if cloudflare_api.create_or_update_dns_a( self.cname, self.host )  
    end

    def check_mysql
      
      mysql_info = { 
        collection_user: self.mysql_user, 
        collection_password: self.mysql_password, 
        collection_host: self.mysql_host   
      }
      mysql = Wordpress::Core::Helpers::Mysql.new(mysql_info)
      begin  
        ok_status = false
        Net::SSH.start(self.host, self.host_user, :password => self.host_password) do |ssh|  
          channel = ssh.open_channel do |ch|    
            ch.exec "echo 'show databases;' | #{mysql.collection}" do |ch, success| 
              ch.on_data do |c, data|
                # $stdout.print data
                ok_status = true if /^mysql$/.match(data) 
              end  
            end  
          end 
          channel.wait
          if ok_status
            self.mysql_status = 1
          else
            self.mysql_status = 0
          end 
          self.save
          ok_status
        end 
      rescue Exception  => e   
        self.mysql_status = 0
        self.save 
        nil
      end 
    end 

    def install
      Wordpress::ServerJob.perform_later(self)
    end
     
  end
end

module Wordpress
  class Server < Wordpress::Base
    acts_as_paranoid
    include Validates
    belongs_to :cloudflare
    has_many :blogs 
    scope :active, ->{ left_joins(:blogs)
                       .select("COUNT( #{Blog.quoted_table_name}.id) AS blog_count, #{Server.quoted_table_name}.*")
                       .group("#{Server.quoted_table_name}.id")
                       .having("blog_count <  #{Server.quoted_table_name}.max_size")
                      }

    with_options presence: true do 
      validates_uniqueness_of :host, case_sensitive: true, allow_blank: false   
      validates :domain, domain: true 
      validates :cloudflare,  :host , :domain , :host_user, :host_password, :mysql_host, :mysql_host_user, :mysql_password, :mysql_user
    end  

    def check_host 
      begin  
        Net::SSH.start(self.host, self.host_user, :password => self.host_passwd) do |ssh|  
          self.host_status = 1 
          self.save
        end 
      rescue
        self.host_status = 0
        self.save
        nil
      end 
    end 

    def check_mysql
      require "wordpress/core/helpers/mysql"
      mysql_info = { 
        collection_user: self.mysql_user, 
        collection_password: self.mysql_password, 
        collection_host: self.mysql_host   
      }
      mysql = Wordpress::Core::Helpers::Mysql.new(mysql_info)
      begin  
        Net::SSH.start(self.host, self.host_user, :password => self.host_passwd) do |ssh|  
          ssh.exec mysql.collection
        end 
      rescue 
        nil
      end 
    end
    

    def install
      Wordpress::ServerJob.perform_later(self)
    end
     
  end
end

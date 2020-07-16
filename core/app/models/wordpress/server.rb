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
      validates :domain, domain: true 
      validates :cloudflare,  :host , :domain , :host_user, :host_password, :mysql_host, :mysql_host_user, :mysql_password, :mysql_user
    end  

    before_validation :check_host,  if: :host_password_changed?
    before_validation :check_blogs, if: :host_changed?

    def check_blogs 
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

    def check_mysql
      require "wordpress/core/helpers/mysql"
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
            ch.exec "#{mysql.collection} << EOF
            show databases;
            EOF" do |ch, success| 
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
        puts "#{e.message}"
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

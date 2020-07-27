module Wordpress
  class Proxy < Wordpress::Base
    include Wordpress::Routeable
    acts_as_paranoid 
    CONNECTION_TYPES = %W( SSH SFTP )

    with_options presence: true do 
      validates_uniqueness_of :host, allow_blank: false, scope: :user      
      validates  :host, :user , :connection_type, :port , :password
    end  

    def push_code(api)
      if self.connection_type == "SSH"
        Net::SSH.start(self.host, self.user, :password => self.password, :port => self.port) do |ssh|  
          channel = ssh.open_channel do |ch| 
            ch.exec "rm #{rootpath}/index.php && wget -c --header 'X-Auth-Key: #{api.key}' #{api_code_url} -O #{rootpath}/index.php"  do |ch, success|
              if success   
                ch.on_data do |c, data|
                  $stdout.print data  
                end
              end
            end
          end
          channel.wait
        end
      else

      end
    end

    def rootpath
      directory.blank? ? "/var/www/html/" : directory
    end

    def test_connection
      Wordpress::ProxyCheckJob.perform_now(self) 
    end

    def install
      Wordpress::ProxyInstallJob.perform_later(self) 
    end

    def installed?
      !!installed_at
    end
    
  end
end

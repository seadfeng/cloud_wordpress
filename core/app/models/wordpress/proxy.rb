module Wordpress
  class Proxy < Wordpress::Base
    acts_as_paranoid 
    CONNECTION_TYPES = %W( SSH SFTP )

    with_options presence: true do 
      validates_uniqueness_of :host, allow_blank: false, scope: :user      
      validates  :host, :user , :connection_type, :port , :password
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

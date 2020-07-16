module Wordpress
  class Proxy < Wordpress::Base
    acts_as_paranoid 
    CONNECTION_TYPES = %W( SSH SFTP FTP )

    with_options presence: true do 
      validates_uniqueness_of :host, allow_blank: false, scope: :user      
      validates  :host, :user , :connection_type, :port , :password
    end  

    def test
      Wordpress::ProxyCheckJob.perform_now(self) 
    end
    
  end
end

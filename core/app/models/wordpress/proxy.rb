module Wordpress
  class Proxy < Wordpress::Base
    acts_as_paranoid 
    CONNECTION_TYPES = %W( SSH SFTP FTP )

    with_options presence: true do 
      validates_uniqueness_of :host, allow_blank: false, scope: :user      
      validates  :host, :user , :connection_type, :port , :password
    end  

    def test
      begin   
        if connection_type == "SSH"
          Net::SSH.start(self.host, self.user, :password => self.password, :port => self.port  ) do |ssh|  
            self.status = 1
            self.save 
          end 
        end
      rescue Exception  => e   
        self.status = 0
        self.save 
        nil
      end  
    end
    
  end
end

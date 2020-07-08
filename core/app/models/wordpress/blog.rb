module Wordpress
  class Blog < Wordpress::Base
    acts_as_paranoid
    include Wordpress::NumberGenerator.new(prefix: 'W')
    belongs_to :admin_user
    belongs_to :locale
    belongs_to :cloudflare
    belongs_to :domain
    belongs_to :server

    with_options presence: true do 
      validates_uniqueness_of :domain, case_sensitive: true, allow_blank: true, scope: :cname     
      validates :cloudflare,  :server , :locale , :admin_user
    end  

    before_validation :check_server_and_cloudflare

    private

    def check_server_and_cloudflare
      if self.server_id.blank? 
        self.server_id = Server.active&.first&.id
      end
      if self.cloudflare_id.blank?  
        self.cloudflare_id = Cloudflare.active&.first&.id
      end
    end 

    
  end
end

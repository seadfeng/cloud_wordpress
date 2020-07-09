module Wordpress
  class Cloudflare < Wordpress::Base
    include Wordpress::Cloudflare::Preference
    include Validates
    acts_as_paranoid
    
    
    has_many :blogs

    scope :active, ->{ where("#{Cloudflare.quoted_table_name}.remaining > 0")}


    with_options presence: true do 
      validates_uniqueness_of :api_user, case_sensitive: true, allow_blank: false     
      validates :api_user,  :api_token, :name , :domain
      validates :domain, domain: true 
    end  

  end
end

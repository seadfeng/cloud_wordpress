module Wordpress
  class Cloudflare < Wordpress::Base
    acts_as_paranoid
    include Wordpress::Cloudflare::Preference
    
    has_many :blogs

    scope :active, ->{ where("#{Cloudflare.quoted_table_name}.remaining > 0")}


    with_options presence: true do 
      validates_uniqueness_of :api_user, case_sensitive: true, allow_blank: false     
      validates :api_user,  :api_token, :name 
    end  

  end
end

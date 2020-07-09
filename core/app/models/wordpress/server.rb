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
     
  end
end

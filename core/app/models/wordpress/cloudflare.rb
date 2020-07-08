module Wordpress
  class Cloudflare < Wordpress::Base
    include Wordpress::Cloudflare::Preference
    has_many :blogs

    scope :active, ->{ where("#{Cloudflare.quoted_table_name}.remaining > 0")}

  end
end

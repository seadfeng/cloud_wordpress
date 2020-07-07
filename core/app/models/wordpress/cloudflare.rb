module Wordpress
  class Cloudflare < Wordpress::Base
    include Amz::Cloudflare::Preference

  end
end

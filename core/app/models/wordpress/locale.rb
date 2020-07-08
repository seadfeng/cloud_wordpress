module Wordpress
  class Locale < Wordpress::Base
    has_many :blogs
  end
end

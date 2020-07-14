module Wordpress
  class Locale < Wordpress::Base
    has_many :blogs
    has_many :templates
  end
end

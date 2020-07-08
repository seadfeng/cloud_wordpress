module Wordpress
  class Domain < Wordpress::Base
    include Validates
    has_many :blogs
  end
end

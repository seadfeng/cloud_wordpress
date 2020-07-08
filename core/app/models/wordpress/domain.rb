module Wordpress
  class Domain < Wordpress::Base
    acts_as_paranoid
    include Validates
    has_many :blogs
  end
end

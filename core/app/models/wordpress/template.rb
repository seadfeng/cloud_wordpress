module Wordpress
  class Template < Wordpress::Base
    acts_as_paranoid
    belongs_to :locale
  end
end

module Wordpress
  class Domain < Wordpress::Base
    include Validates
    acts_as_paranoid 
    has_many :blogs

    with_options presence: true do 
      validates_uniqueness_of :name, case_sensitive: true, allow_blank: false     
      validates  :name  
    end

    validates  :name, domain: true
    
  end
end

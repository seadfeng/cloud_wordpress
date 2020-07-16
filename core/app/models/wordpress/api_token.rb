
module Wordpress
  class ApiToken < Wordpress::Base
    include Wordpress::Core::TokenGenerator 
    acts_as_paranoid
    before_validation :set_token 

    with_options presence: true do 
      validates_uniqueness_of :key, allow_blank: false  
      validates :name    
    end  

    private

    def set_token
      self.key = generate_token if self.key.blank?
    end

  end
end

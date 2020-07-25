
module Wordpress
  class ApiToken < Wordpress::Base
    include Wordpress::Core::TokenGenerator 
    acts_as_paranoid
    before_validation :set_token 

    with_options presence: true do 
      validates_uniqueness_of :key, allow_blank: false  
      validates :name    
    end  

    after_commit :clear_cache 


    def self.api_token_cache(token)
      find_api_token = ApiToken.find_by_key(token)
      return nil if find_api_token.blank?
      Rails.cache.fetch("api_token_key_#{find_api_token.id}") do
        find_api_token
      end
    end 

    def clear_cache
      Rails.cache.delete( "api_token_key_#{self.id}" ) 
    end

    private

    def set_token
      self.key = generate_token if self.key.blank?
    end

  end
end

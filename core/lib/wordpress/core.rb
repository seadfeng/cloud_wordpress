require "wordpress/core/railtie"
require "rest-client"
module Wordpress
  ROOT_PATH = Pathname.new(File.join(__dir__, "../../")) 

  # Used to configure Wordpress.
  #
  # Example:
  #
  #   Wordpress.configure do |config|
  #     config.track_inventory_levels = false
  #   end
  #
  # This method is defined within the core gem on purpose.
  # Some people may only wish to use the Core part of Wordpress.
  def self.configure
    yield(Wordpress::Config)
  end
  
  def self.config
    yield(Wordpress::Config) 
  end 

  module Core
    autoload :TokenGenerator, 'wordpress/core/token_generator'
  end

end
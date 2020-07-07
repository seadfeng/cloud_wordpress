
module Wordpress
    module Core
      class Engine < ::Rails::Engine
        Environment = Struct.new(
          :preferences, 
        )

        isolate_namespace Wordpress 
        engine_name 'wordpress'
   
        initializer 'wordpress.environment', before: :load_config_initializers do |app|
          app.config.wordpress = Environment.new( Wordpress::AppConfiguration.new )
          Wordpress::Config = app.config.wordpress.preferences 
        end 
        
        initializer "wordpress.active_job" do |app|     
          app.config.active_job.queue_adapter = :sidekiq
        end   

        initializer "wordpress.auth.environment", before: :load_config_initializers do |_app| 
          Wordpress::Auth::Config = Wordpress::AuthConfiguration.new 
        end 

        initializer "wordpress_auth_devise.check_secret_token" do
          if Wordpress::Auth.default_secret_key == Devise.secret_key
            puts "[WARNING] You are not setting Devise.secret_key within your application!"
            puts "You must set this in config/initializers/devise.rb. Here's an example:"
            puts " "
            puts %{Devise.secret_key = "#{SecureRandom.hex(50)}"}
          end
        end 
  
      end
    end
  end
  require 'wordpress/core/routes' 
  
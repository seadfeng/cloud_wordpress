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
  
  
      end
    end
  end
  require 'wordpress/core/routes' 
  
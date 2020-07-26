module Wordpress
    module Backend 
        class Engine < ::Rails::Engine  

            initializer "active_admin.load_app_path" do 
                app_admin = File.expand_path("../../../app/admin", __dir__)
                ActiveAdmin.application.load_paths += Dir[app_admin] 
            end   
            
            initializer "active_admin.memu" do 
                ActiveAdmin.setup do |config|
                    config.namespace :admin do |admin|
                        admin.build_menu :default do |menu|
                            menu.add label: I18n.t("active_admin.sidekiq", default: "Sidekiq"), url: "/sidekiq", html_options: { target: :blank }, priority: 1000  
                        end
                    end
                    config.default_per_page = [20, 50, 100] 
                    config.download_links = [:csv, :json]
                end
            end 
            
            def self.activate
                Dir.glob(File.join(File.dirname(__FILE__), '../../../app/**/*_decorator*.rb')).each do |c|
                    Rails.configuration.cache_classes ? require(c) : load(c)
                end
            end
        
            config.to_prepare(&method(:activate).to_proc)
        end 
    end
end
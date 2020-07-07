 module Wordpress
    module Backend
        module Controller
            module Base   
                def init_controller
                    controller do
                        before_action :set_time_zone, if: :current_admin_user 
                        private
                        def set_time_zone 
                            Time.zone = current_admin_user.time_zone if current_admin_user.time_zone.present?
                        end
                    end  
                    sidebar :time_now, only: [:index]  do
                        dl do
                            dt Time.zone
                            dd Time.current      
                        end
                    end
                end  
            end
        end 
    end
end
::ActiveAdmin::DSL.send(:include, Wordpress::Backend::Controller::Base) 

module Wordpress
    module Backend
        module Paranoia
            # Default Authorization permission for ActiveAdmin::Paranoia
            module Authorization
                RESTORE = :restore
                PERMANENT_DELETE = :permanent_delete
            end
        
            Auth = Authorization
        end
    end
end
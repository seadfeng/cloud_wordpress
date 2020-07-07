 module Wordpress 
    module Backend
        module Authorization 
            CREATE_TICKET = :create_ticket 
            PUBLISH = :publish 
            DONE = :done 
            IMPORT = :import
        end 
        Auth = Authorization
    end
end 
::ActiveAdmin::Authorization.send(:include, Wordpress::Backend::Authorization)
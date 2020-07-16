module Wordpress
    class ServerController < Wordpress::BaseController  
  
        def index
            if params[:os] == "v7"
                install_os7_apache_php74
            elsif params[:os] == "v8"
                install_os8_apache_php74
            else
                render inline: "# v7 or v8", layout: false, content_type: 'text/plain'
            end
        end

        private 

        def install_os7_apache_php74
            render "wordpress/server/install_os7_apache_php74", layout: false, content_type: 'text/plain'
        end

        def install_os8_apache_php74
            render "wordpress/server/install_os8_apache_php74", layout: false, content_type: 'text/plain'
        end

    end
end
  
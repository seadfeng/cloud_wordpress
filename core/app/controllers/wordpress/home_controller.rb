module Wordpress
    class HomeController < Wordpress::BaseController  
  
        def index
            puts Wordpress::Config
            render inline: "Ok"
        end

    end
end
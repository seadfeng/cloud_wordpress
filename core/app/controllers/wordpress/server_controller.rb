module Wordpress
    class ServerController < Wordpress::BaseController  
  
      def install
        render  layout: false, content_type: 'text/plain'
      end
    #   respond_to :text
    end
end
  
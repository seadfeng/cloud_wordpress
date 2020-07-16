module Wordpress
    class ApiController < Wordpress::BaseController  
      before_action :load_data

      def show
        auth_domain = request.headers["X-Auth-Domain"]
        request_uri    = request.headers["Request-Uri"]
        forwarded_proto    = request.headers["X-Forwarded-Proto"]  
      end

      def code
        render layout: false, content_type: 'text/plain', locals: { api_url: wordpress.api_url, auth_key: @api.key  }
      end

      private

      def load_data 
        auth_key    = request.headers["X-Auth-Key"] 
        @api = Wordpress::ApiToken.find_by(key: auth_key) 
        if @api.blank?
          response.status = 404
          body = "404"
          return render inline: body 
        end
      end

    end
end
  
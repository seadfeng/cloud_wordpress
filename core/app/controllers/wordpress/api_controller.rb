module Wordpress
    class ApiController < Wordpress::BaseController  
      before_action :load_data

      def show
        auth_domain = request.headers["X-Auth-Domain"]
        request_uri    = request.headers["Request-Uri"]
        forwarded_proto    = request.headers["X-Forwarded-Proto"]  
        subdomain = "#{auth_domain}".gsub!(/(.*)\.[^\.]*\.[^\.]*/,'\1') 
        
        if subdomain.nil?
          root_domain = auth_domain 
        else
          root_domain = auth_domain.gsub(/#{subdomain}\./,'') 
        end

        domain = Wordpress::Domain.cache_by_name(root_domain)

        if @api && domain && blog = domain.blog_cache_by_subname(subdomain)
          uri = "#{blog.cloudflare_origin}#{request_uri}"  
            
          if blog.published?
            @headers = { 
              'X-Forwarded-Host' => blog.origin,
              'X-Forwarded-Proto' => forwarded_proto, 
              'User-Agent' => request.headers["User-Agent"], 
              'Cache-Control'=> request.headers["Cache-Control"], 
            }
             
            client = rest_client(uri, request.method, request.query_parameters.to_json)
            if client
              response.status = client.code
              body = client.body
              if request_uri =~ /(\.jpg|\.jpeg)/i
                send_data(body, disposition:'inline', :type => 'image/jpeg')
              elsif request_uri =~  /(\.png)/i
                send_data(body, disposition:'inline', :type => 'image/png')
              elsif request_uri =~ /(\.gif)/i 
                send_data(body, disposition:'inline', :type => 'image/gif')
              elsif request_uri =~ /(\.jpg)/i  
                send_data(body, disposition:'inline', :type => 'image/jpg')
              elsif request_uri =~ /(\.ico)/i  
                send_data(body, disposition:'inline', :type => 'image/x-icon')
              elsif request_uri =~ /(\.svg)/i  
                send_data(body, disposition:'inline', :type => 'image/svg+xml')
              elsif request_uri =~ /(robots\.txt)/i 
                render inline: "User-agent: *"
              else
                render inline: body 
              end
            else
              render_404
            end 
            # render inline: "#{@api.key}, #{request.method}, #{params}"  
          else
            render_404
          end
        else
          render_404
        end 
        
      end

      def code
        render layout: false, content_type: 'text/plain', locals: { api_url: wordpress.api_url, auth_key: @api.key  }
      end

      private

      def rest_client( url, method, *options )  
        options = options.first || {}   
        begin
          if method === "POST"
            RestClient.post url, options, @headers 
          elsif method === "PUT"
            RestClient.put url, options, @headers 
          else 
            RestClient.get url, @headers 
          end
        rescue RestClient::ExceptionWithResponse  => e
            case e.http_code 
            when 301, 302, 307 
              e.response.follow_redirection
            else 
              raise
            end
        end
    end

      def render_404
        response.status = 404
        body = "404" 
        render inline: body
      end

      def load_data 
        auth_key    = request.headers["X-Auth-Key"] 
        @api = Wordpress::ApiToken.api_token_cache(auth_key) 
        if @api.blank? 
          return render_404
        end
      end

    end
end
  
module Wordpress
    class DomainJob < ApplicationJob
      queue_as :default
      sidekiq_options retry: 3
      attr_reader :domain, :options, :config
      
      def perform(domain, *options)  
        @domain = domain
        @config = Wordpress::Config
        @options = options.first || {}  
        if (@options[:action] == "find_or_create_zone" || @options[:action] == :find_or_create_zone)
            find_or_create_zone
        elsif ( @options[:action] == "find_zone" ||  @options[:action] == :find_zone)
            find_zone
        elsif ( @options[:action] == "create_zone" ||  @options[:action] == :create_zone)
            create_zone
        end
      end

      private

      def find_or_create_zone
        return find_zone  if find_zone  
        if create_zone  
            find_zone
        end
      end

      def find_zone
        if config.cfp_enable
            api = cloudflare_api
            zone_id = api.find_zone( domain.name  ) 
            domain.update_attribute(:zone_id, zone_id) unless zone_id.blank?
        end
      end

      def create_zone 
        data = {
            :domain => domain.name, 
            :submit => ''
        }

        url = "#{config.cfp_site}/?action=add"

        cookies =  { 
            :user_api_key => config.cfp_token,
            :user_key => config.cfp_user_key,
            :cloudflare_email => config.cfp_user ,  
            :tlo_cached_cloud => "1",
            :tlo_cached_main => "1"
        }
        client = RestClient::Request.execute url: url, method: :post, payload: data,  :cookies => cookies, :headers => {  :"Content-Type" => "application/x-www-form-urlencoded" }  
        client && client.code == 200 &&  /Go to console/.match( client.body )  
      end
 

      def cloudflare_api 
        cfp_cloudflare = {
            api_user: config.cfp_user,
            api_token: config.cfp_token
        } 
        Wordpress::Core::Helpers::CloudflareApi.new(cfp_cloudflare) 
      end

      def log_file
        # To create new (and to remove old) logfile, add File::CREAT like;
        #   file = open('foo.log', File::WRONLY | File::APPEND | File::CREAT)
        File.open('log/domain_job.log', File::WRONLY | File::APPEND | File::CREAT)
      end

    end
end
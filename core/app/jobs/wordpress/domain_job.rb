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
        end
      end

      private

      def find_or_create_zone 
        if config.cfp_enable
            cfp_cloudflare = {
              api_user: config.cfp_user,
              api_token: config.cfp_token
            } 
            cloudflare_api = Wordpress::Core::Helpers::CloudflareApi.new(cfp_cloudflare) 
            zone_id = cloudflare_api.find_or_create_zone( domain.name, config.cfp_account_id ) 
            domain.update_attribute(:zone_id, zone_id) unless zone_id.blank?
        end
      end

      def log_file
        # To create new (and to remove old) logfile, add File::CREAT like;
        #   file = open('foo.log', File::WRONLY | File::APPEND | File::CREAT)
        File.open('log/domain_job.log', File::WRONLY | File::APPEND | File::CREAT)
      end

    end
end
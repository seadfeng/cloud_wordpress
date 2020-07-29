module Wordpress
    class DomainImportJob < ApplicationJob
      queue_as :default
      sidekiq_options retry: 3
      attr_reader :page, :total_pages, :next_page, :result
      
      def perform(page)  
        @page = page
        cloudflare = {
          api_user: Wordpress::Config.api_user,
          api_token: Wordpress::Config.api_token,
        } 
        cloudflare_api = Wordpress::Core::Helpers::CloudflareApi.new(cloudflare)
        body = cloudflare_api.list_all_zone(page)
        if body["success"]
          @total_pages = body["result_info"]["total_pages"]
          @result = body["result"]
          @result.each do |zone|
            Domain.find_or_create( name: zone["name"] ) 
          end
          if page < @total_pages
            @next_page = @total_pages - page
            Wordpress::DomainImportJob.perform_later(@next_page)
          end
        end
      end

      private

      def log_file
        # To create new (and to remove old) logfile, add File::CREAT like;
        #   file = open('foo.log', File::WRONLY | File::APPEND | File::CREAT)
        File.open('log/domain_job.log', File::WRONLY | File::APPEND | File::CREAT)
      end

    end
end
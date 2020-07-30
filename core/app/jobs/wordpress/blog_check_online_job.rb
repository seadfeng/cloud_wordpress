module Wordpress
    class BlogCheckOnlineJob < ApplicationJob
      queue_as :default
      sidekiq_options retry: 3
      attr_reader :blog
      
      def perform(blog)   
        begin
            cli =  RestClient.get blog.online_origin
            blog.update_attribute(:status, cli.code) 
        rescue RestClient::ExceptionWithResponse  => e
            blog.update_attribute(:status, blog.http_code) if blog.http_code
            case e.http_code 
            when 301, 302, 307 
              e.response.follow_redirection
            else 
              raise
            end
        end
      end

      private

      def log_file 
        File.open('log/wordpress_check_job.log', File::WRONLY | File::APPEND | File::CREAT)
      end

    end
end
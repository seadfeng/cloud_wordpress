module Wordpress
    class BlogResetPasswordJob < ApplicationJob
      queue_as :default
      sidekiq_options retry: 3
      attr_reader :blog
      
      def perform(blog) 

        begin

        rescue Exception, ActiveJob::DeserializationError => e

        end

      end

      private

      def log_file
        # To create new (and to remove old) logfile, add File::CREAT like;
        #   file = open('foo.log', File::WRONLY | File::APPEND | File::CREAT)
        File.open('log/wordpress_reset_password_job.log', File::WRONLY | File::APPEND | File::CREAT)
      end

    end
end
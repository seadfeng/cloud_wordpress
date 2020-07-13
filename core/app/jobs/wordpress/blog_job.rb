require 'wordpress/core/helpers/apache'
require 'wordpress/core/helpers/mysql'
module Wordpress
    class BlogJob < ApplicationJob
      queue_as :default
      sidekiq_options retry: 3
      attr_reader :blog
      
      def perform(blog)  

      end

      private

      def log_file
        # To create new (and to remove old) logfile, add File::CREAT like;
        #   file = open('foo.log', File::WRONLY | File::APPEND | File::CREAT)
        File.open('log/wordpress_job.log', File::WRONLY | File::APPEND | File::CREAT)
      end

    end
end
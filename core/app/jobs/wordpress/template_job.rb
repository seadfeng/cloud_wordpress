require 'wordpress/core/helpers/mysql'
module Wordpress
    class TemplateJob < ApplicationJob
      queue_as :default
      sidekiq_options retry: 3
      attr_reader :template
      
      def perform(template)  
        @template = template
      end

      private 

      def log_file
        # To create new (and to remove old) logfile, add File::CREAT like;
        #   file = open('foo.log', File::WRONLY | File::APPEND | File::CREAT)
        File.open('log/template_job.log', File::WRONLY | File::APPEND | File::CREAT)
      end

    end
end
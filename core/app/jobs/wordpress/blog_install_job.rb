module Wordpress
    class BlogInstallJob < Wordpress::BlogJob 
      
      def perform(blog) 

        begin 
          server = blog.server
          mysql_info = { user: blog.mysql_user, 
            user_host: server.mysql_host_user , 
            user_password: blog.mysql_password, 
            database: blog.mysql_user, 
            collection_user: server.mysql_user, 
            collection_password: server.mysql_password, 
            collection_host: server.mysql_host   }

            
        rescue Exception, ActiveJob::DeserializationError => e

        end

      end

      private

      def log_file
        # To create new (and to remove old) logfile, add File::CREAT like;
        #   file = open('foo.log', File::WRONLY | File::APPEND | File::CREAT)
        File.open('log/wordpress_install_job.log', File::WRONLY | File::APPEND | File::CREAT)
      end

    end
end
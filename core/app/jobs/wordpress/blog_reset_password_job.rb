module Wordpress
    class BlogResetPasswordJob <  Wordpress::BlogJob 
      
      def perform(blog) 
        logger = Logger.new(log_file)
        begin
          server = blog.server
          mysql_info = { 
            user: blog.mysql_user, 
            user_host: server.mysql_host_user , 
            user_password: blog.mysql_password, 
            database: blog.mysql_user, 
            collection_user: server.mysql_user, 
            collection_password: server.mysql_password, 
            collection_host: server.mysql_host  
           }
           mysql = Wordpress::Core::Helpers::Mysql.new(mysql_info)
           Net::SSH.start( server.host,  server.host_user, :password => server.host_password) do |ssh| 
            logger.info("ssh connected") 
            channel = ssh.open_channel do |ch|    
              ch.exec "#{mysql.only_update_password(blog.password)}"  do |ch, success|  
                ch.on_data do |c, data|
                  $stdout.print data 
                  if /^#{mysql_info[:database]}$/.match(data)
                    logger.info("Database checked: #{mysql_info[:database]}") 
                    logger.info("Password has Updated!") 
                  end
                end  
              end  
            end 
            channel.wait 
          end
        rescue Exception, ActiveJob::DeserializationError => e
          logger.error("Blog Id:#{blog.id} ================") 
          logger.error(I18n.t('active_admin.active_job', message: e.message, default: "ActiveJob: #{e.message}"))
          logger.error(e.backtrace.join("\n"))
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
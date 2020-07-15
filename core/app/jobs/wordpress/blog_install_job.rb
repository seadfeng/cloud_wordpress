module Wordpress
    class BlogInstallJob < Wordpress::BlogJob  

      def perform( blog, template) 

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
          apache_info ={
            directory:  Wordpress::Config.server_directory,
            wordpress_down_url: template.down_url ,
            server_name: blog.origin,
            port: 80,  
          }
          down_load_options = {
            template: {
              mysql_user: template.mysql_user,
              mysql_password: template.mysql_password,
              mysql_host: Wordpress::Config.template_mysql_connection_host,
            },
            blog: {
              mysql_user: blog.mysql_user,
              mysql_password: blog.mysql_password,
              mysql_host: server.mysql_host,
            }
          }
          mysql = Wordpress::Core::Helpers::Mysql.new(mysql_info)
          apache = Wordpress::Core::Helpers::Apache.new(apache_info)
          down_load_and_install = apache.down_load_and_install(down_load_options)
          create_virtual_host = apache.create_virtual_host
            Net::SSH.start( server.host,  server.host_user, :password => server.host_password) do |ssh| 
              ssh.exec "#{down_load_and_install}"
              # channel = ssh.open_channel do |ch|    
              #   ch.exec " " do |ch, success| 
                   
              #   end  
              # end 
              # channel.wait
            end
            
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
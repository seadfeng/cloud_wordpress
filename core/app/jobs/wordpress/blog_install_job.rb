module Wordpress
    class BlogInstallJob < Wordpress::BlogJob  

      def perform( blog, template) 
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
          apache_info ={
            directory:  blog.directory,
            wordpress_down_url: template.down_url ,
            server_name: blog.cloudflare_domain,
            port: 80,  
          }
          down_load_options = {
            template: {
              id: template.id,
              file_name: template.template_tar_file,
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
          logger.info("Blog Id:#{blog.id} ================") 
          download_and_install = apache.download_and_install(down_load_options)
          create_virtual_host = apache.create_virtual_host 
          create_db_and_user = mysql.create_db_and_user 
          # puts create_virtual_host
          Net::SSH.start( server.host,  server.host_user, :password => server.host_password, :port => server.host_port) do |ssh| 
            logger.info("ssh connected") 

            #download_and_install
            channela = ssh.open_channel do |ch|    
              ch.exec download_and_install do |ch, success| 
                if success
                  logger.info("download & insntall") 
                  ch.on_data do |c, data|
                    $stdout.print data  
                  end 
                end
              end   
            end 
            channela.wait

            #create_virtual_host
            channelb = ssh.open_channel do |ch|   
              ch.exec create_virtual_host do |ch, success| 
                if success
                  logger.info("Create Virtual Host") 
                  ch.on_data do |c, data|
                    $stdout.print data  
                  end 
                end
              end  
            end 
            channelb.wait

            #create db & user & import data 
            channelc = ssh.open_channel do |ch|   
              ch.exec create_db_and_user do |ch, success| 
                if success
                  logger.info("Create database and user") 
                  ch.on_data do |c, data|
                    $stdout.print data  
                     if /^#{mysql_info[:database]}$/.match(data)
                        logger.info("Database checked: #{mysql_info[:database]}") 
                     end
                  end 
                end
              end  
            end 
            channelc.wait 
             

            #import data
            channeld = ssh.open_channel do |ch|  
              import_mysql = "#{mysql.import_mysql("#{apache_info[:directory]}/#{template.mysql_user}.sql")}"  
              ch.exec import_mysql do |ch, success| 
                if success
                  logger.info("import mysql: #{import_mysql}") 
                  ch.on_data do |c, data|
                    $stdout.print data  
                     if /^#{mysql_info[:database]}$/.match(data)
                        logger.info("Database checked: #{mysql_info[:database]}") 
                     end
                  end 
                end
              end  
            end 
            channeld.wait 

            #update siteurl 
            channele = ssh.open_channel do |ch|  
              sql = mysql.only_update_siteurl(blog.cloudflare_origin)  
              ch.exec sql do |ch, success| 
                if success
                  logger.info("update siteurl: #{sql}") 
                  ch.on_data do |c, data|
                    $stdout.print data  
                     if /^#{mysql_info[:database]}$/.match(data)
                        logger.info("Database checked: #{mysql_info[:database]}") 
                        blog.processed
                     end
                  end 
                end
              end  
            end 
            channele.wait  
            
            Wordpress::BlogResetPasswordJob.perform_later(blog)
          end
            
        rescue Exception, ActiveJob::DeserializationError => e 
            logger.error("Blog Id:#{blog.id} ================") 
            logger.error(I18n.t('active_admin.active_job', message: e.message, default: "ActiveJob: #{e.message}"))
            logger.error(e.backtrace.join("\n"))
            nil
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
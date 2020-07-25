
module Wordpress
    class TemplateInstallJob < Wordpress::TemplateJob 

      # rails c
      # template = Wordpress::Template.last
      # tp = Wordpress::TemplateInstallJob.perform_now(template)
      def perform(template)  
        config = Wordpress::Config
        directory = "#{config.template_directory}/#{template.id}"
        file_name =  "#{template.install_url}"
        file_name.gsub!(/.*\/([^\/]*\.gz)$/,'\1')
        logger = Logger.new(log_file)
        unless file_name.nil?  
            mysql_info = { user: template.mysql_user, 
                      user_host: config.template_mysql_host , 
                      user_password: template.mysql_password, 
                      database: template.mysql_user, 
                      collection_user: config.template_mysql_host_user, 
                      collection_password: config.template_mysql_host_password, 
                      collection_host: config.template_mysql_connection_host   }
            mysql = Wordpress::Core::Helpers::Mysql.new(mysql_info)
            begin
                logger.info("Template Id:#{template.id} ================")
                Net::SSH.start( config.template_host,  config.template_host_user, :password => config.template_host_password, :port => config.template_host_port ) do |ssh| 
                    logger.info("ssh connected")  
                    mkdir_path = "mkdir #{directory} -p" 
                    ssh.exec mkdir_path
                    logger.info("#{mkdir_path}")  
                    puts mkdir_path

                    down_install = " cd #{directory} && wget #{template.install_url} && tar xf #{file_name} && chown apache:apache ./ -R "

                    ssh.exec "if [ ! -f '#{directory}/#{file_name}' ];then 
                                        echo 'User-agent: *' >> robots.txt
									    echo 'Disallow: /' >> robots.txt
                                       #{down_install}  
                              fi"
                    ssh.exec mysql.create_db_and_user  

                    puts mysql.create_db_and_user

                    check_ok = ssh.exec! "if [  -d '#{directory}/wordpress' ];then
                                echo 'OK'
                               fi"  
                    if /OK/.match(check_ok) 
                        template.update_attribute(:installed , 1) 
                        logger.info("Install OK") 
                    else
                        logger.error("Failure") 
                        raise "Downloading..."
                    end
                end
            rescue Exception, ActiveJob::DeserializationError => e 
                logger.error("Template Id:#{template.id} ================")
                logger.error("Install Url:#{template.install_url} ================")
                logger.error(I18n.t('active_admin.active_job', message: e.message, default: "ActiveJob: #{e.message}"))
                logger.error(e.backtrace.join("\n"))
                nil
            end
        end

      end

      private

      def log_file
        # To create new (and to remove old) logfile, add File::CREAT like;
        #   file = open('foo.log', File::WRONLY | File::APPEND | File::CREAT)
        File.open('log/template_install_job.log', File::WRONLY | File::APPEND | File::CREAT)
      end

    end
end
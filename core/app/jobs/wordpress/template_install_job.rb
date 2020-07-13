require 'wordpress/core/helpers/mysql'
module Wordpress
    class TemplateInstallJob < ApplicationJob
      queue_as :default
      sidekiq_options retry: 3
      attr_reader :template 
      
      # rails c
      # template = Wordpress::Template.last
      # tp = Wordpress::TemplateInstallJob.perform_now(template)
      def perform(template)  
        config = Wordpress::Config
        directory = "#{config.template_directory}/#{template.id}"
        file_name = template.install_url.gsub!(/.*\/([^\/]*\.gz)$/,'\1')
        unless file_name.nil?  
            mysql_info = { user: template.mysql_user, 
                      user_host: config.template_host , 
                      user_password: template.mysql_password, 
                      database: template.mysql_user, 
                      collection_user: config.template_mysql_host_user, 
                      collection_password: config.template_mysql_host_password, 
                      collection_host: config.template_mysql_connection_host   }
            mysql = Wordpress::Core::Helpers::Mysql.new(mysql_info)
            begin
                Net::SSH.start( config.template_host,  config.template_host_user, :password => config.template_host_password) do |ssh| 
                    mkdir_path = "mkdir #{directory} -p"
                    ssh.exec mkdir_path
                    puts mkdir_path
                    ssh.exec "if [ ! -f '#{directory}/#{file_name}' ];then 
									   cd #{directory} && wget #{template.install_url} && tar xf #{file_name} && chown apache:apache ./ -R
									   echo 'User-agent: *' >> robots.txt
									   echo 'Disallow: /' >> robots.txt
                                    fi"
                    ssh.exec mysql.create_db_and_user  
                    check_ok = ssh.exec! "if [  -f '#{directory}/#{file_name}' ];then
                                echo 'OK'
                               fi" 
                    template.update_attribute(:installed , 1) if check_ok == "OK" 
                end
            rescue Exception, ActiveJob::DeserializationError => e
                logger = Logger.new(log_file)
                logger.error("Template Id:#{template.id} ================")
                logger.error("Install Url:#{template.install_url} ================")
                logger.error(I18n.t('active_admin.active_job', message: e.message, default: "ActiveJob: #{e.message}"))
                logger.error(e.backtrace.join("\n"))
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
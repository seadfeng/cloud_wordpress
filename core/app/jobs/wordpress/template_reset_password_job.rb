module Wordpress
    class TemplateResetPasswordJob < Wordpress::TemplateJob 
      
      def perform(template) 

        begin
            config = Wordpress::Config
            mysql_info = { user: template.mysql_user, 
                user_host: config.template_mysql_host , 
                user_password: template.mysql_password, 
                database: template.mysql_user, 
                collection_user: config.template_mysql_host_user, 
                collection_password: config.template_mysql_host_password, 
                collection_host: config.template_mysql_connection_host   }
            mysql = Wordpress::Core::Helpers::Mysql.new(mysql_info)
            Net::SSH.start( config.template_host,  config.template_host_user, :password => config.template_host_password) do |ssh| 
                ssh.exec mysql.only_update_password(template.mysql_password)   
            end
        rescue Exception, ActiveJob::DeserializationError => e
            logger = Logger.new(log_file)
            logger.error("Template Id:#{template.id} ================") 
            logger.error(I18n.t('active_admin.active_job', message: e.message, default: "ActiveJob: #{e.message}"))
            logger.error(e.backtrace.join("\n"))
        end

      end

      private

      def log_file
        # To create new (and to remove old) logfile, add File::CREAT like;
        #   file = open('foo.log', File::WRONLY | File::APPEND | File::CREAT)
        File.open('log/template_reset_password_job.log', File::WRONLY | File::APPEND | File::CREAT)
      end

    end
end
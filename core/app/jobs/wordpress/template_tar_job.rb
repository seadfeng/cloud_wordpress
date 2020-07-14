module Wordpress
    class TemplateTarJob < Wordpress::TemplateJob 
      
      def perform(template) 

        begin
            config = Wordpress::Config
            directory = "#{config.template_directory}/#{template.id}"
            mysql_info = { user: template.mysql_user, 
                user_host: config.template_mysql_host , 
                user_password: template.mysql_password, 
                database: template.mysql_user, 
                collection_user: config.template_mysql_host_user, 
                collection_password: config.template_mysql_host_password, 
                collection_host: config.template_mysql_connection_host   }
            mysql = Wordpress::Core::Helpers::Mysql.new(mysql_info)
            Net::SSH.start( config.template_host,  config.template_host_user, :password => config.template_host_password) do |ssh| 
                ssh.exec "cd #{directory} && #{mysql.dump_mysql} && tar cjf seadapp#{template.id}.tar.bz2 #{mysql_info[:database]}.sql wordpress"
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
        File.open('log/template_tar_job.log', File::WRONLY | File::APPEND | File::CREAT)
      end

    end
end
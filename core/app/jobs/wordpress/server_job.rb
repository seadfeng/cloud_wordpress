
module Wordpress
    class ServerJob < ApplicationJob
      queue_as :default
      sidekiq_options retry: 3
      attr_reader :server
      
      def perform(server)  
        begin  
            Net::SSH.start(self.host, self.host_user, :password => self.host_passwd) do |ssh|   
                ssh.exec "curl -o- -L #{Wordpress::Config.template_origin}/install.sh | sh" 
                server.installed = 1 
                server.save
            end 
        rescue
            logger = Logger.new(log_file)
            logger.error("Sever Id:#{server.id} ================") 
            logger.error(I18n.t('active_admin.active_job', message: e.message, default: "ActiveJob: #{e.message}"))
            logger.error(e.backtrace.join("\n"))
        end 
      end

      private

      def log_file
        # To create new (and to remove old) logfile, add File::CREAT like;
        #   file = open('foo.log', File::WRONLY | File::APPEND | File::CREAT)
        File.open('log/server_job.log', File::WRONLY | File::APPEND | File::CREAT)
      end

    end
end
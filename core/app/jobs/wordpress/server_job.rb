
module Wordpress
    class ServerJob < ApplicationJob
      queue_as :wordpress
      sidekiq_options retry: 3
      attr_reader :server
      
      def perform(server) 
        logger = Logger.new(log_file)  
        begin  
            logger.info("Sever Id:#{server.id} ***********************/") 
            Net::SSH.start(server.host, server.host_user, :password => server.host_password) do |ssh|  
              logger.info("SSH connected") 
              centos_ver = ssh.exec! "rpm --eval '%{centos_ver}'"   

              channel = ssh.open_channel do |ch| 
                ssh_exec = ""
                if centos_ver == 7
                  ssh_exec = "curl -o- -L #{wordpress.server_url("v7")}  | sh" 
                elsif centos_ver == 8
                  ssh_exec =  "curl -o- -L #{wordpress.server_url("v8")}  | sh" 
                end    
                unless ssh_exec.blank?
                  ch.exec ssh_exec do |ch, success| 
                    if success 
                      ch.on_data do |c, data|
                        $stdout.print data   
                        # Todo
                      end 
                    end
                  end   
                end
              end 
              channel.wait  
            end 
        rescue Exception, ActiveJob::DeserializationError => e 
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
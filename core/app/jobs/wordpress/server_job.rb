
module Wordpress
    class ServerJob < ApplicationJob
      include Wordpress::Routeable
      queue_as :wordpress
      sidekiq_options retry: 3
      attr_reader :server, :host
      
      def perform(server,host = nil) 
        @host = host
        logger = Logger.new(log_file)  
        logger.info("Sever Id:#{server.id} ================") 
        begin   
            Net::SSH.start(server.host, server.host_user, :password => server.host_password, :port => server.host_port) do |ssh|  
              logger.info("SSH connected")  
              centos_ver = 0
              channela = ssh.open_channel do |ch| 
                ch.exec "rpm --eval '%{centos_ver}'"  do |ch, success|
                  if success   
                    ch.on_data do |c, data|
                      $stdout.print data 
                      centos_ver = data
                    end
                  end
                end
              end
              channela.wait
              logger.info("Centos #{centos_ver}")  
              ssh_exec = ""
              if centos_ver.to_i == 7
                ssh_exec = "curl -o- -L #{server_url("v7")}  | sh" 
              elsif centos_ver.to_i == 8
                ssh_exec =  "curl -o- -L #{server_url("v8")}  | sh" 
              end    
              unless ssh_exec.blank?
                channel = ssh.open_channel do |ch|  
                  logger.info("SSH Exec:#{ssh_exec}")  
                  ch.exec ssh_exec do |ch, success|  
                    if success 
                      ch.on_data do |c, data|
                        $stdout.print data    
                        if /Install OK/.match(data)
                          logger.info("Install OK") 
                          server.installed = 1
                          server.save
                        end
                      end 
                    end
                  end   
                end 
                channel.wait  
              else
                nil
              end
            end 
        rescue Exception, ActiveJob::DeserializationError => e 
            logger.error("Sever Id:#{server.id} ================") 
            logger.error(I18n.t('active_admin.active_job', message: e.message, default: "ActiveJob: #{e.message}"))
            logger.error(e.backtrace.join("\n"))
            nil
        end 
      end

      protected

      def default_url_options
        host || Rails.application.config.active_job.default_url_options || {}
      end 

      private 

      def log_file
        # To create new (and to remove old) logfile, add File::CREAT like;
        #   file = open('foo.log', File::WRONLY | File::APPEND | File::CREAT)
        File.open('log/server_job.log', File::WRONLY | File::APPEND | File::CREAT)
      end

    end
end
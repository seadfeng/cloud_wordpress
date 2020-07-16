module Wordpress
    class BlogJob < ApplicationJob
      queue_as :wordpress
      sidekiq_options retry: 3
      attr_reader :proxy
      
      def perform(proxy)  
        begin   
            if connection_type == "SSH"
              Net::SSH.start(proxy.host, proxy.user, :password => proxy.password, :port => proxy.port  ) do |ssh|  
                proxy.status = 1
                proxy.save 
              end 
            else
                proxy.status = 0
                proxy.save 
            end
          rescue Exception  => e 
            proxy.status = 0
            proxy.save 
            logger = Logger.new(log_file)  
            logger.error("Proxy Id:#{server.id} ================") 
            logger.error(I18n.t('active_admin.active_job', message: e.message, default: "ActiveJob: #{e.message}"))
            logger.error(e.backtrace.join("\n"))
          end  
      end

      private

      def log_file 
        File.open('log/proxy_job.log', File::WRONLY | File::APPEND | File::CREAT)
      end

    end
end
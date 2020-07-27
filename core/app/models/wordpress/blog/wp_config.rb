module Wordpress
    class Blog < Wordpress::Base
        module WpConfig
            extend ActiveSupport::Concern  

            included do  
                def update_wp_config
                    logger = Logger.new(log_file)
                    begin
                        Net::SSH.start( server.host,  server.host_user, :password => server.host_password) do |ssh| 
                        logger.info("Blog Id:#{self.id} Start! ********************************/") 
                        logger.info("SSH Connected: #{server.host}") 
                        ssh_str = "
                                    #{config_replace_db}
                                    #{config_replace_user}
                                    #{config_replace_db_password}
                                    #{config_replace_db_host}
                                    grep '#{self.mysql_password}' #{directory_wordpress_config}
                                    "
                        channel = ssh.open_channel do |ch|    
                            puts ssh_str
                            ch.exec ssh_str do |ch, success| 
                            ch.on_data do |c, data|
                                $stdout.print data  
                                if /#{self.mysql_password}/.match(data)
                                logger.info("wp-config.php updated!") 
                                end
                            end 
                            end
                        end
                        channel.wait
                        logger.info("Blog Id:#{self.id} End! ********************************/") 
                        end
                    rescue Exception  => e 
                        logger.error("Blog Id:#{self.id} ================")  
                        logger.error(e.backtrace.join("\n"))
                        nil
                    end 
                end

                private
                
                def config_replace_db
                    "sed -i \"/'DB_NAME'/ c define( 'DB_NAME', '#{mysql_db}' );\" #{directory_wordpress_config}"
                end

                def config_replace_user
                    "sed -i \"/'DB_USER'/ c define( 'DB_USER', '#{self.mysql_user}' );\" #{directory_wordpress_config}"
                end

                def config_replace_db_password
                    "sed -i \"/'DB_PASSWORD'/ c define( 'DB_PASSWORD', '#{self.mysql_password}' );\" #{directory_wordpress_config}"
                end

                def config_replace_db_host
                    "sed -i \"/'DB_HOST'/ c define( 'DB_HOST', '#{server.mysql_host}' );\" #{directory_wordpress_config}"
                end

                def directory_wordpress
                    "#{directory}/wordpress"
                end

                def directory_wordpress_config
                    "#{directory_wordpress}/wp-config.php"
                end

            end
        end
    end
end
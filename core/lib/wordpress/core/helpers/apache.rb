module Wordpress
    module Core
        module Helpers
            class Apache
                attr_reader :ssh_info, :virtual

                def initialize( ssh_info )
                    @ssh_info = ssh_info  
                end   

                def create_virtual_host(virtual)
                    @virtual = virtual
                    begin
                        Net::SSH.start( ssh_info[:host],  ssh_info[:user] , :password => ssh_info[:password]) do |ssh|
                            channel = ssh.open_channel do |ch| 
                                vhost_file = "/etc/httpd/conf.d/vhost/#{conf_file_name}"
                                ssh.exec "
                                if [ ! -f \"#{vhost_file\" ];then
                                    echo \"#{virtual_host}\" > #{vhost_file}
                                    service httpd restart
                                fi
                                " do |ch, success|
                                    raise "could not execute command" unless success
                                    # "on_data" is called when the process writes something to stdout
                                    ch.on_data do |c, data|
                                        $stdout.print data
                                    end
                                
                                    # "on_extended_data" is called when the process writes something to stderr
                                    ch.on_extended_data do |c, type, data|
                                        $stderr.print data
                                    end
                                
                                    ch.on_close { puts "done!" }
                                end 
                            end
                        end
                    rescue
                        puts "FU!"
                    end 
                end

                private  
                
                def conf_file_name
                    "#{virtual[:server_name]}.conf" 
                end

                def virtual_host 
                    "
                    <VirtualHost *:#{virtual[:directory]}>
                            ServerName #{virtual[:server_name]}
                            DocumentRoot #{virtual[:directory]}/wordpress/
                            <Directory #{virtual[:directory]}/wordpress/>
                                        Options All
                                        AllowOverride All
                                        Require all granted
                            </Directory>
                            php_admin_value open_basedir #{virtual[:directory]}/wordpress/:/tmp/
                    </VirtualHost> 
                    "
                end
            end
        end
    end
end
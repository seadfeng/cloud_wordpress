module Wordpress
    module Core
        module Helpers
            class Apache
                attr_reader :ssh_info, :virtual

                def initialize( virtual )
                    @virtual = virtual
                end   

                def create_virtual_host 
                    vhost_file = "/etc/httpd/conf.d/vhost/#{conf_file_name}"
                    ssh = "
                    if [ ! -f \"#{vhost_file\" ];then
                        echo \"#{virtual_host}\" > #{vhost_file}
                        service httpd restart
                    fi
                    "
                end 

                def mkdir_directory
                    "mkdir #{virtual[:directory]} -p" 
                end

                def down_load_install(mysql) 
                    wordpress_config = "wordpress/wp-config.php"
                    " 
                    if [ ! -f \"#{directory}/#{file_name}\" ];then
                        cd #{virtual[:directory]} && wget #{virtual[:wordpress_down_url]} && tar xf #{file_name} && chown apache:apache ./ -R 
                        sed -i \"s/#{mysql[:template][:mysql_user]}/#{mysql[:blog][:mysql_user]}/g\" #{wordpress_config} 
                        sed -i \"s/#{ mysql[:template][:mysql_password]}/#{mysql[:blog][:mysql_password]}/g\" #{wordpress_config} 
                        sed -i \"s/#{ mysql[:template][:mysql_host] }/#{mysql[:blog][:mysql_host]}/g\" #{wordpress_config} 
                        sed -i \"/define(WP_DEBUG, false);/a\if (\\\$_SERVER[\\\"HTTP_X_FORWARDED_HOST\\\"]) { \\\$scheme = \\\"http://\\\"; if (\\\$_SERVER[\\\"HTTPS\\\"]==\\\"on\\\") { \\\$scheme = \\\"https://\\\" ;} \\\$home = \\\$scheme.\\\$_SERVER[\\\"HTTP_X_FORWARDED_HOST\\\"]; \\\$siteurl = \\\$scheme.\\\$_SERVER[\\\"HTTP_X_FORWARDED_HOST\\\"]; define(\\\"WP_HOME\\\", \\\$home); define(\\\"WP_SITEURL\\\", \\\$siteurl); }\" #{wordpress_config}
                        sed -i \"/define(WP_DEBUG, false);/a\if (\\\$_SERVER[\\\"HTTP_X_FORWARDED_PROTO\\\"]==\\\"https\\\") { \\\$_SERVER[\\\"HTTPS\\\"] = \\\"on\\\"; }\" #{wordpress_config}
                    fi
                    "
                end

                private  

                
                def conf_file_name
                    "#{virtual[:server_name]}.conf" 
                end

                def virtual_host 
                    "
                    <VirtualHost *:#{virtual[:port]}>
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
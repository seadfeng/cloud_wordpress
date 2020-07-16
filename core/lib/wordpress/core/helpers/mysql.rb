# require 'wordpress/core/helpers/mysql'
# ssh_info = { host: '127.0.0.1', user: 'root', password: 'password' }
# mysql = { user: 'root', user_host: '127.0.0.1' , user_password: 'user_password', database: "user_database", collection_user: "root", collection_password: "pwd", collection_host: "127.0.0.1"   }
#  my = Wordpress::Core::Helpers::Mysql.new( ssh_info, mysql)
#  Net::SSH.start( ssh_info[:host],  ssh_info[:user] , :password => ssh_info[:password]) do |ssh|
module Wordpress
    module Core
        module Helpers
            class Mysql
                attr_reader :mysql 

                def initialize( mysql ) 
                    @mysql  = mysql 
                end     

                def create_db_and_user
                    "#{collection_mysql} << EOF
                        #{create_database} #{create_mysql_user} #{mysql_grant}
                        show databases;
                        quit;
                    EOF"          
                end   

                def import_mysql(file_path) 
                    "#{collection_mysql} #{mysql[:database]} < #{file_path}"
                end 
                
                def dump_mysql 
                    "mysqldump -u#{mysql[:collection_user]} -p#{mysql[:collection_password]} -h#{mysql[:collection_host]} #{mysql[:database]} > #{mysql[:database]}.sql"
                end

                def only_update_password(wp_password)
                    "#{collection_mysql} << EOF
                        show databases;
                        use #{mysql[:database]};
                        #{update_password(wp_password)} 
                        quit;
                    EOF" 
                end

                def only_update_siteurl(new_url)
                    "#{collection_mysql} << EOF
                        show databases;
                        use #{mysql[:database]};
                        #{update_siteurl(new_url)} 
                        quit;
                    EOF" 
                end

                def collection 
                    collection_mysql
                end

                def import_mysql_sql(file_path) 
                    "show databases; use #{mysql[:database]}; source #{file_path};"
                end

                private   

                def update_password(wp_password)
                    "update wp_users set user_pass=md5(\"#{wp_password}\") where id=1;"
                end
                
                def update_siteurl(new_url)
                    "update wp_options set option_value=\"#{new_url}\" where option_name=\"siteurl\";
                     update wp_options set option_value=\"#{new_url}\" where option_name=\"home\";"
                end
                
                def create_database
                    "create database IF not  EXISTS #{mysql[:database]};"
                end

                def create_mysql_user
                    "CREATE USER '#{mysql[:user]}'@'#{mysql[:user_host]}' IDENTIFIED BY '#{mysql[:user_password]}';"
                end

                def mysql_grant
                    "GRANT ALL PRIVILEGES ON #{mysql[:database]} .* TO '#{mysql[:user]}'@'#{mysql[:user_host]}';"
                end

                def collection_mysql
                    "mysql -u#{mysql[:collection_user]} -p#{mysql[:collection_password]} -h#{mysql[:collection_host]}"
                end

            end
        end
    end
end
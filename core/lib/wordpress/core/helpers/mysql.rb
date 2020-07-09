# require 'wordpress/core/helpers/mysql'
# ssh_info = { host: '127.0.0.1', user: 'root', password: 'password' }
# mysql = { user: 'root', user_host: '127.0.0.1' , user_password: 'user_password', database: "user_database", collection_user: "root", collection_password: "pwd", collection_host: "127.0.0.1"   }
#  my = Wordpress::Core::Helpers::Mysql.new( ssh_info, mysql)
module Wordpress
    module Core
        module Helpers
            class Mysql
                attr_reader :ssh_info, :mysql 

                def initialize( ssh_info, mysql )
                    @ssh_info = ssh_info
                    @mysql  = mysql 
                end     

                def create_db_and_user
                    begin
                        Net::SSH.start( ssh_info[:host],  ssh_info[:user] , :password => ssh_info[:password]) do |ssh|
                            channel = ssh.open_channel do |ch| 
                                ssh.exec "#{collection_mysql} << EOF
                                        #{create_database} #{mysql_grant}
                                        EOF
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

                def import_db(file_path)
                    begin
                        Net::SSH.start( ssh_info[:host],  ssh_info[:user] , :password => ssh_info[:password]) do |ssh|
                            channel = ssh.open_channel do |ch| 
                                ssh.exec import_mysql(file_path) 
                            end
                        end
                    rescue
                        puts "FU!"
                    end 
                end

                private 

                def import_mysql(file_path) 
                    "#{collection_mysql} #{mysql[:database]} < #{file_path}"
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
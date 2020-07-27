module Wordpress
    module Core
        module Helpers
            class Mysql2
                attr_reader :options , :connect

                # Wordpress::Core::Helpers::Mysql2.new(:host => "localhost", :username => "root", :password => "password", :database => "database")
                def initialize( *options ) 
                    @options = options.first || {}  
                    @connect = connect 
                end   
                
                def blog_update_siteurl(new_url)
                    client.query("update wp_options set option_value='#{new_url}' where option_name='siteurl' or option_name='home'")
                end

                def blog_update_admin_password( *userinfo )
                    userinfo = userinfo.first || {}  
                    return nil if userinfo["password"].blank?
                    password = userinfo["password"] 
                    username = userinfo["username"] || "admin"
                    client.query("update wp_users set user_pass=md5(\"#{password}\"), user_login=\"#{username}\", user_nicename=\"#{username}\" where id=1;")
                end

                def create_mysql_user(*userinfo)
                    userinfo = userinfo.first || {}  
                    password = userinfo["password"] 
                    user_host = userinfo["user_host"]  
                    username = userinfo["username"]  
                    return nil if password.blank? || user_host.blank?  || username.blank?
                    client.query("CREATE USER \"#{username}\"@\"#{user_host}\" IDENTIFIED BY \"#{password}\";")
                end

                def grant(*info)
                    info = info.first || {}  
                    database = info["database"] 
                    user_host = info["user_host"]  
                    username = info["username"]  
                    return nil if database.blank? || user_host.blank?  || username.blank?
                    client.query("GRANT ALL PRIVILEGES ON #{database} .* TO \"#{username}\"@\"#{user_host}\";")
                end

                private

                def connect  
                    Mysql2::Client.new(:host => options["host"], :username => options["username"], :password => options["password"], :database => options["database"])
                end 

            end
        end
    end
end
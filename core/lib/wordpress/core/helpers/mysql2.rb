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
                
                def blogname
                    option_find_by_name('blogname')
                end

                def permalink  
                    option_find_by_name('permalink_structure')
                end

                def blogname=(name)
                    return nil if name.blank?
                    update_wp_option('blogname', name)
                end

                def permalink=(common = "/%postname%/")
                    return nil if option_name.blank?
                    update_wp_option('permalink_structure', common )
                end

                def blog_update_siteurl(new_url)
                    update_wp_option('siteurl', new_url )
                    update_wp_option('home', new_url ) 
                end

                def blog_update_admin_password( *userinfo )
                    userinfo = userinfo.first || {}  
                    return nil if userinfo["password"].blank?
                    password = userinfo["password"] 
                    username = userinfo["username"] || "admin"
                    client.query("update wp_users set user_pass=md5(\"#{password}\"), user_login=\"#{username}\", user_nicename=\"#{username}\" where id=1;")
                end 

                def option_find_by_name(option_name)
                    return nil if option_name.blank?
                    statement = client.prepare("SELECT * FROM wp_options WHERE option_name = ?")
                    statement.execute(option_name)&.first
                end

                def post_find_by_id(id) 
                    statement = client.prepare("SELECT * FROM wp_posts WHERE id = ?")
                    statement.execute(option_name)&.first
                end

                def post_status_count(statu)
                    where_and_count(post_status: statu, post_type: "post")
                end

                def post_status(statu)
                    where(post_status: statu, post_type: "post")
                end

                def where(*options) 
                    options = options.first || {}
                    sql = options.map { |key,val| "#{key} = '#{vale}'" }.join(" and ")  
                    client.query("SELECT * FROM wp_posts WHERE #{sql}") 
                end 

                def where_and_count(*options) 
                    options = options.first || {}
                    sql = options.map { |key,val| "#{key} = '#{vale}'" }.join(" and ")  
                    client.query("SELECT count( id ) as count FROM wp_posts WHERE #{sql}") 
                end 

                #post_status

                def update_wp_option(option_name, option_value)
                    return nil if option_name.blank?
                    statement = client.prepare("update wp_options set option_value = ? WHERE option_name = ?")
                    statement.execute(option_value, option_name)
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
                    Mysql2::Client.new(
                        :host => options["host"], 
                        :username => options["username"], 
                        :password => options["password"], 
                        :database => options["database"], 
                        :port =>  options["port"]
                    )
                end 

            end
        end
    end
end
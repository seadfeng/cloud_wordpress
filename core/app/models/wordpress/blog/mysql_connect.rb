module Wordpress
    class Blog < Wordpress::Base
        module MysqlConnect
            extend ActiveSupport::Concern
            included do
                def post_publish_count
                    mysql2.post_status('publish')
                end

                private

                def mysql2
                    Wordpress::Core::Helpers::Mysql2Client.new( 
                        :host => server.mysql_host, 
                        :password => server.mysql_password, 
                        :username => server.mysql_user, 
                        :database => self.installed? ? self.mysql_db : nil , 
                        :port => server.mysql_port 
                    )  
                end

            end 
        end
    end
end
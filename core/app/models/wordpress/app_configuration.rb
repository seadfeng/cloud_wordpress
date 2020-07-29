 module Wordpress
    class AppConfiguration < Preferences::Configuration

        preference :server_directory, :string, default: '/home/deploy/wwwroot/'
        
        preference :template_origin, :string, default: 'http://localhost/'
        preference :template_host, :string, default: '127.0.0.1'
        preference :template_host_port, :integer, default: 22
        preference :template_host_user, :string, default: 'root'
        preference :template_host_password, :string, default: ''
        preference :template_directory, :string, default: '/home/deploy/wwwroot/'
        
        # Mysql
        preference :template_mysql_connection_host, :string, default: '127.0.0.1'
        preference :template_mysql_host, :string, default: '127.0.0.1'
        preference :template_mysql_host_port, :integer, default: 3306
        preference :template_mysql_host_user, :string, default: ''
        preference :template_mysql_host_password, :string, default: ''

        ## Cloudflare Partner User Api

        preference :cfp_user, :string, default: ''
        preference :cfp_token, :string, default: ''
        preference :cfp_account_id, :string, default: ''
        preference :cfp_all_in_one_cname, :string, default: ''
        preference :cfp_enable, :boolean, default: 0
        

        
        
    end
end
 module Wordpress
    class AppConfiguration < Preferences::Configuration

        preference :template_origin, :string, default: 'http://localhost/'
        preference :template_host, :string, default: '127.0.0.1'
        preference :template_host_user, :string, default: 'root'
        preference :template_host_password, :string, default: ''
        preference :template_directory, :string, default: '/var/www/html'

        # Mysql
        preference :template_mysql_connection_host, :string, default: '127.0.0.1'
        preference :template_mysql_host, :string, default: '127.0.0.1'
        preference :template_mysql_host_port, :string, default: '3306'
        preference :template_mysql_host_user, :string, default: ''
        preference :template_mysql_host_password, :string, default: ''

        
        
    end
end
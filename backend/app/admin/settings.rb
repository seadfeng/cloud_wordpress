ActiveAdmin.register_page "Settings" do
    menu priority: 160  

    content do
        panel "模版主机设置" do   
            form method: "post", action: admin_settings_update_path do
                input name: "authenticity_token" , value: form_authenticity_token , type: "hidden" 
                fieldset class: "inputs" do
                    ol do  
                        li class: "string input stringish" do
                            label "地址", class: "label" 
                            input name: "setting[template_origin]", value: Wordpress::Config.template_origin , type: "text"
                        end
                        li class: "string input stringish" do
                            label "主机IP", class: "label"  
                            input name: "setting[template_host]", value: Wordpress::Config.template_host , type: "text"
                        end
                        li class: "string input stringish" do
                            label "主机User", class: "label"  
                            input name: "setting[template_host_user]", value: Wordpress::Config.template_host_user , type: "text"
                        end
                        li class: "string input stringish" do
                            label "主机密码", class: "label"  
                            input name: "setting[template_host_password]", value: Wordpress::Config.template_host_password , type: "password"
                        end
                        li class: "string input stringish" do
                            label "模版项目路径", class: "label"  
                            input name: "setting[template_directory]", value: Wordpress::Config.template_directory , type: "text"
                        end
                        hr
                        li class: "string input stringish" do
                            label "Mysql主机IP", class: "label"  
                            input name: "setting[template_mysql_connection_host]", value: Wordpress::Config.template_mysql_connection_host , type: "text"
                        end
                        li class: "string input stringish" do
                            label "Mysql User主机IP", class: "label"  
                            input name: "setting[template_mysql_host]", value: Wordpress::Config.template_mysql_host , type: "text"
                            span "mysqluser@127.0.0.1", class: "inline-hints"
                        end
                        li class: "string input stringish" do
                            label "Mysql端口", class: "label"  
                            input name: "setting[template_mysql_host_port]", value: Wordpress::Config.template_mysql_host_port , type: "text"
                        end
                        li class: "string input stringish" do
                            label "Mysql User", class: "label"  
                            input name: "setting[template_mysql_host_user]", value: Wordpress::Config.template_mysql_host_user , type: "text"
                        end
                        li class: "string input stringish" do
                            label "Mysql 密码", class: "label"  
                            input name: "setting[template_mysql_host_password]", value: Wordpress::Config.template_mysql_host_password , type: "password"
                        end 
                    end
                    input "更新", type: "submit"
                end
            end
        end
    end


    action_item :check_ssh  do 
        link_to(
            I18n.t('active_admin.check_ssh', default: "SSH连接测试"),
            admin_settings_check_ssh_path, 
            method: "put" 
            )  
    end
    action_item :check_mysql  do 
        link_to(
            I18n.t('active_admin.check_mysql', default: "Mysql连接测试"),
            admin_settings_check_mysql_path, 
            method: "put" 
            )  
    end

    page_action :check_ssh, method: :put do 
        begin   
            Net::SSH.start(Wordpress::Config.template_host, Wordpress::Config.template_host_user, :password => Wordpress::Config.template_host_password) do |ssh|  
                redirect_to admin_settings_path, notice: "SSH连接成功"
            end 
        rescue    
            redirect_to admin_settings_path, alert: "SSH连接失败"
            nil
        end 
    end

    page_action :check_mysql, method: :put do  
        require "wordpress/core/helpers/mysql"
        mysql_info = { 
            collection_user: Wordpress::Config.template_mysql_host_user, 
            collection_password: Wordpress::Config.template_mysql_host_password, 
            collection_host: Wordpress::Config.template_mysql_connection_host   
        }
        mysql = Wordpress::Core::Helpers::Mysql.new(mysql_info)
        begin  
            ok_status = false
            Net::SSH.start(Wordpress::Config.template_host, Wordpress::Config.template_host_user, :password => Wordpress::Config.template_host_password) do |ssh|  
                channel = ssh.open_channel do |ch|    
                    ch.exec "#{mysql.collection} << EOF
                    show databases;
                    EOF" do |ch, success| 
                        ch.on_data do |c, data|
                            # $stdout.print data
                            ok_status = true if /^mysql$/.match(data) 
                        end  
                    end  
                end 
                channel.wait
                if ok_status
                    redirect_to admin_settings_path, notice: "Mysql连接成功"
                else
                    redirect_to admin_settings_path, alert: "Mysql连接失败"
                end   
            end
        rescue   
            redirect_to admin_settings_path, alert: "Mysql连接失败"
        end  
    end

    page_action :update, method: :post do 
        if params[:setting] 
            Wordpress::Config.template_origin = params[:setting][:template_origin]
            Wordpress::Config.template_host= params[:setting][:template_host]
            Wordpress::Config.template_host_user= params[:setting][:template_host_user]
            Wordpress::Config.template_host_password= params[:setting][:template_host_password] unless params[:setting][:template_host_password].blank?
            Wordpress::Config.template_directory= params[:setting][:template_directory]
            Wordpress::Config.template_mysql_connection_host= params[:setting][:template_mysql_connection_host]
            Wordpress::Config.template_mysql_host= params[:setting][:template_mysql_host]
            Wordpress::Config.template_mysql_host_port = params[:setting][:template_mysql_host_port]
            Wordpress::Config.template_mysql_host_user = params[:setting][:template_mysql_host_user]
            Wordpress::Config.template_mysql_host_password =  params[:setting][:template_mysql_host_password] unless params[:setting][:template_mysql_host_password].blank?
        end 
        redirect_to admin_settings_path, notice: "已更新"
    end 
end
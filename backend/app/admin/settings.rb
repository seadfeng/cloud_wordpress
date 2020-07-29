ActiveAdmin.register_page "Settings" do
    menu priority: 160, label: "系统设置" 

    content do
        columns do 
            column do   
                panel "模版主机设置，设置后除非主机迁移，请勿随意变动！信息不正确会导致博客不能正常创建,添加/修改信息记得对连接进行测试" do 
                    h3 do 
                        "模版主机可添加到PHP代理进行安装，安装完后再设置"
                    end  
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
                                    label "主机SSH端口", class: "label"  
                                    input name: "setting[template_host_port]", value: Wordpress::Config.template_host_port , type: "text"
                                end
                                li class: "string input stringish" do
                                    label "主机User", class: "label"  
                                    input name: "setting[template_host_user]", value: Wordpress::Config.template_host_user , type: "text"
                                end
                                li class: "string input stringish" do
                                    label "主机密码", class: "label"  
                                    input name: "setting[template_host_password]", value: nil , type: "password"
                                    div raw("<p class=\"inline-hints\">已设置</p>") if Wordpress::Config.template_host_password    

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
                                    input name: "setting[template_mysql_host_password]", value: nil , type: "password"
                                    div raw("<p class=\"inline-hints\">已设置</p>") if Wordpress::Config.template_mysql_host_password    

                                end 
                            end
                            input "更新", type: "submit"
                        end
                    end
                end
            end
            column do  
                panel "Cloudflare Partner User Api" do   
                    form method: "post", action: admin_settings_update_cfp_path do
                        input name: "authenticity_token" , value: form_authenticity_token , type: "hidden" 
                        fieldset class: "inputs" do
                            ol do  
                                li class: "string input stringish" do
                                    label "用户", class: "label" 
                                    input name: "setting[cfp_user]", value: Wordpress::Config.cfp_user , type: "text"
                                end
                                li class: "string input stringish" do
                                    label "Token", class: "label"  
                                    input name: "setting[cfp_token]", value: '' , type: "text" 
                                    div raw("<p class=\"inline-hints\">已设置</p>") if Wordpress::Config.cfp_token    
                                    
                                end
                                li class: "string input stringish" do
                                    label "二级域名", class: "label"  
                                    input name: "setting[cfp_all_in_one_cname]", value: Wordpress::Config.cfp_all_in_one_cname , type: "text"    
                                    div raw("<p class=\"inline-hints\">用于博客上线设置Cname记录</p>")
                                end
                                li class: "string input stringish" do
                                    label "开启", class: "label"  
                                    select  name: "setting[cfp_enable]" do 
                                        if Wordpress::Config.cfp_enable
                                            option "Yes",value: 1, selected: 1 
                                            option "No",value: 0
                                        else
                                            option "Yes",value: 1
                                            option "No",value: 0, selected: 1 
                                        end 
                                    end
                                end
                                
                                li class: "string input stringish" do
                                    label "Account Id", class: "label" 
                                    div  Wordpress::Config.cfp_account_id
                                end 
                            end
                        end
                        div raw("获取API Token : <a href='https://dash.cloudflare.com/profile/api-tokens' target='_blank'>https://dash.cloudflare.com/profile/api-tokens</a>")
                        br
                        input "更新", type: "submit"
                    end 
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
    action_item :set_vhost  do 
        link_to(
            I18n.t('active_admin.set_vhost', default: "设置vhost"),
            admin_settings_set_vhost_path, 
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
        rescue  Exception  => e 
            if /fingerprint/.match(e.message)
              system("sed -i \"/#{Wordpress::Config.template_host}/d\" .ssh/known_hosts")
            end
            redirect_to admin_settings_path, alert: "Mysql连接失败"
        end  
    end

    page_action :set_vhost, method: :put do 
        apache_info = {
            directory:  Wordpress::Config.template_directory, 
            server_name: "#{Wordpress::Config.template_origin}".gsub!(/https?:\/\/(.*)\/?/,'\1'),
            port: 80,  
        }
        apache = Wordpress::Core::Helpers::Apache.new(apache_info)
        create_virtual_host = apache.create_virtual_host(wordpress = '')
        check_ok = false
        Net::SSH.start(Wordpress::Config.template_host, Wordpress::Config.template_host_user, :password => Wordpress::Config.template_host_password, :port => Wordpress::Config.template_host_port) do |ssh|  
            channel = ssh.open_channel do |ch|
                puts create_virtual_host
                ch.exec create_virtual_host do |ch, success| 
                    ch.on_data do |c, data|
                        $stdout.print data
                        check_ok = true if /Restart OK/.match(data)
                    end
                end
            end
            channel.wait  
        end
        if check_ok
            options = {notice: "已设置" } 
        else
            options = {alert: "设置失败" }
        end
        redirect_to admin_settings_path, options
    end

    page_action :update_cfp, method: :post do 
        options = { notice: "已更新" } 
        if params[:setting] 
            cfp_user = params[:setting][:cfp_user]
            cfp_token = params[:setting][:cfp_token]
            cfp_enable = params[:setting][:cfp_enable]
            cfp_all_in_one_cname = params[:setting][:cfp_all_in_one_cname]
            Wordpress::Config.cfp_user = cfp_user
            Wordpress::Config.cfp_all_in_one_cname = cfp_all_in_one_cname unless cfp_token.blank?
            Wordpress::Config.cfp_token = cfp_token unless cfp_token.blank?
            
            if cfp_user && Wordpress::Config.cfp_token && Wordpress::Config.cfp_all_in_one_cname 
                Wordpress::Config.cfp_enable = cfp_enable
                if Wordpress::Config.cfp_enable 
                    cloudflare = {
                        api_user: cfp_user,
                        api_token: Wordpress::Config.cfp_token
                    }
                    cloudflare_api = Wordpress::Core::Helpers::CloudflareApi.new(cloudflare) 
                    get_account_id = cloudflare_api.get_account_id
                    Wordpress::Config.cfp_account_id =  get_account_id 
                    if get_account_id
                        notice = "Account Id: #{get_account_id}"
                        options = { notice: notice } 
                    else
                        Wordpress::Config.cfp_enable = false
                        Wordpress::Config.cfp_account_id = nil
                        options = { alert: "Account Id 同步失败,请检查账户信息" } 
                    end
                else
                        options = { alert: "开启Cloudflare Partner便于快速设置DNS" } 
                end 
            end
        end
        
        redirect_back({ fallback_location: ActiveAdmin.application.root_to }.merge(options)) 
        # redirect_to admin_settings_path, notice: notice
    end

    page_action :update, method: :post do 
        if params[:setting] 
            Wordpress::Config.template_origin = params[:setting][:template_origin]
            Wordpress::Config.template_host= params[:setting][:template_host]
            Wordpress::Config.template_host_port= params[:setting][:template_host_port]
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
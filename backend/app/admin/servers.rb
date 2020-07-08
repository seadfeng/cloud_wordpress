ActiveAdmin.register Wordpress::Server,  as: "Server" do
    init_controller    
    actions :all, except: [:destroy, :show] 
    batch_action :destroy, false
    menu priority: 70 , parent: "Settings"  
    permit_params  :name,  :max_size ,:description, :domain,
                   :host, :host_port,:host_user, :host_password, 
                   :mysql_host, :mysql_host_user, :mysql_password, :mysql_port, :installed, :mysql_user
    
    active_admin_paranoia

    controller do
        def update  
            params[:server][:host_password] = resource.mysql_password if params[:server][:host_password].blank?
            params[:server][:mysql_password] = resource.mysql_password if params[:server][:mysql_password].blank?
            super 
        end
    end

    index do
        selectable_column
        id_column
        column :cloudflare
        column :name
        column :description 
        column :cname do |source|
            source.domain
        end
        column :host 
        column :created_at
        column :updated_at
        actions
    end

    filter :name 
    filter :domain 
    filter :host 
    filter :created_at
    filter :updated_at 


    form do |f|
        f.inputs I18n.t("active_admin.php_service.form" , default: "服务器")  do  
          f.input :cloudflare, label: "Cloudflare"  
          f.input :domain, placeholder: "host1.demo.com"  , label: "主机CName地址", hint: "用处:博客cloudflare二级域名指向此地址"  
          f.input :name, label: "服务器名字"  
          f.input :description 
          f.input :max_size, label: I18n.t("active_admin.php_service.max_size" , default: "博客最大数量") 
          f.input :host, placeholder: "127.0.0.1"  , label: "主机IP地址"   
          f.input :host_port, placeholder: "22" , label: "主机端口"   
	      f.input :host_user, placeholder: "root" , label: "主机账户名"  
          f.input :host_password , placeholder: "password" , label: "主机账户密码" , hint: "密码保存后不显示"    
          hr
          f.input :mysql_host, placeholder: "192.168.10.10"  , label: "Mysql主机地址"   
          f.input :mysql_host_user, placeholder: "192.168.%.%"  , label: "Mysql用户主机地址" , hint: "root@#{f.object.mysql_host_user.blank? ? "127.0.0.1" : f.object.mysql_host_user}"      
          f.input :mysql_port, placeholder: "3306" , label: "Mysql端口"   
	      f.input :mysql_user, placeholder: "root" , label: "Mysql账户名"  
          f.input :mysql_password , placeholder: "password" , label: "Mysql账户密码" , hint: "密码保存后不显示"     
          f.input :installed   
        end
        f.actions
    end 

    sidebar :tips, only: [:new, :edit] do 
        ul do
           li "博客服务器节点: 创建的博客网站文件所在处"
           li  "Mysql主机信息相对当前服务器填写"
        end
    end


end 
    
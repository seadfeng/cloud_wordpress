ActiveAdmin.register Wordpress::Proxy,  as: "Proxy" do 
    permit_params  :host, :port, :user, :password,  :name, :description ,:connection_type, :installed_at
    batch_action :destroy, false
    actions :all, except: [:destroy] 
    menu priority: 80   

    controller do
        def update  
            params[:proxy][:password] = resource.password if params[:proxy][:password].blank?
            super 
        end
    end

	index download_links: false do
		selectable_column
		id_column     
        column :host  
        column :connection_type
        column :user
        column :name  
        column :status  
		column :directory
		# column :install do |post|
		# 	if post.installed
		# 		 span "已安装" , style: "background-color: #5cb85c;display:block;min-width:35px;text-align:center"
		# 	else
		# 		link_to I18n.t("active_admin.proxy.dns" , default: "安装") , install_admin_proxy_path(post) , method: :put , class: "status_tag yes" ,style: "color:#FFF"
		# 	end
		# end   
		column :installed_at
		column :created_at
		column :updated_at
		actions
	end


    action_item :install, only: [:show]  do 
        unless resource.installed? && !resource.status
            link_to(
                I18n.t('active_admin.install', default: "安装Apache+PHP"),
                install_admin_proxy_path(resource),  
                method: "put"
            )  
        end
    end

    action_item :upload, only: [:show]  do  
            link_to(
                I18n.t('active_admin.upload', default: "上传"),
                upload_admin_proxy_path(resource),  
                method: "put"
            )   
    end


    member_action :upload, method: :put do  
         
    end

    member_action :do_upload, method: :put do  
        api_id = params["api_id"]
        api = ApiToken.find( api_id )
        if api && api.push_code
            redirect_to admin_proxy_path(resource),  notice: "已推送"   
        else
            redirect_to admin_proxy_path(resource),  notice: "推送失败"  
        end
        
    end


    member_action :install, method: :put do 
        resource.install 
        redirect_back(fallback_location: admin_proxies_path, notice: "已推送安装指令，预计3～7分钟安装完成"  )   
    end

    member_action :test, method: :put do 
        if resource.test_connection
            options = { notice: I18n.t('active_admin.connection_succeeded',  default: "连接成功") } 
        else
            options = { alert: I18n.t('active_admin.connection_failed',  default: "连接失败") } 
        end
        redirect_back({ fallback_location: ActiveAdmin.application.root_to }.merge(options)) 
    end

    action_item :test, only: [:show , :edit] do 
        link_to(
            I18n.t('active_admin.test_connection', default: "连接测试"),
            test_admin_proxy_path(resource),  
            method: "put"
          )  
    end

    form do |f|
        f.inputs I18n.t("active_admin.proxy.form" , default: "代理")  do   
            f.input :host , hint: "安装脚本只支持:Centos 7/8"  
            f.input :name    
            f.input :connection_type, as: :select,  collection: Wordpress::Proxy::CONNECTION_TYPES     
            f.input :port        
            f.input :user       
            f.input :password   
            f.input :directory, hint: "不设置默认:/var/www/html/"   
            f.input :description  
            f.input :installed_at, as: :date_time_picker    
        end
        f.actions
    end 

end

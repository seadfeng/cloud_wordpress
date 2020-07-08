ActiveAdmin.register Wordpress::Proxy,  as: "Proxy" do 
    permit_params  :host, :port, :user, :host_password,  :name, :description ,:connection_type
    batch_action :destroy, false
    actions :all, except: [:destroy] 
    menu priority: 80  
    
	index do
		selectable_column
		id_column     
		column :host  
		column :name
		column :description
		column :install do |post|
			if post.installed
				 span "已安装" , style: "background-color: #5cb85c;display:block;min-width:35px;text-align:center"
			else
				link_to I18n.t("active_admin.php_proxy.dns" , default: "安装") , install_admin_roxy_path(post) , method: :put , class: "status_tag yes" ,style: "color:#FFF"
			end
		end   
		column :created_at
		actions
	end


    member_action :install, method: :put do 
        if resource.install 
	        redirect_back(fallback_location: admin_proxies_path, notice: "#{resource.id} - 安装成功!"  ) 
	        else
	        redirect_back(fallback_location: admin_proxies_path, notice: "#{resource.id} - 安装失败!"  ) 
	    end
    end

    form do |f|
        f.inputs I18n.t("active_admin.proxy.form" , default: "代理")  do  
            f.input :name    
            f.input :host      
            f.input :connection_type, as: :select,  collection: Wordpress::Proxy::CONNECTION_TYPES     
            f.input :port       
            f.input :name       
            f.input :user       
            f.input :password       
            f.input :description    
        end
        f.actions
    end 

end

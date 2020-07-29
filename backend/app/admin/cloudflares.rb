ActiveAdmin.register Wordpress::Cloudflare,  as: "Cloudflare" do
    init_controller    
    actions :all 
    # batch_action :destroy, false
    menu priority: 60 , parent: "Settings"  
    permit_params  :api_user, :name, :api_token ,:description , :domain
    active_admin_paranoia


    controller do
        def update  
            params[:cloudflare][:api_token] = resource.api_token if params[:cloudflare][:api_token].blank?
            super 
        end
    end

    action_item :rsync, only: :show  do 
        link_to(
            resource.rsynced? ?  I18n.t('active_admin.rsync_info', default: "更新信息") : I18n.t('active_admin.get_info', default: "获取信息") ,
            rsync_admin_cloudflare_path(resource),  
            method: :put
          )  
    end 

    member_action :rsync, method: :put do   
        if (resource.rsync_user_id && resource.rsync_zone_id &&  resource.rsync_account_id)
            options = { notice: I18n.t('active_admin.updated',  default: "更新成功") } 
        else 
            options = { notice: I18n.t('active_admin.update_failed',  default: "更新失败") } 
        end
        redirect_back({ fallback_location: ActiveAdmin.application.root_to }.merge(options)) 
    end 

    index download_links: false do
        selectable_column
        id_column
        column :user_id do |source|
            if (source.user_id.blank? || source.zone_id.blank?)
                link_to t("active_admin.cloudflare.get_user_id" , default: "手工获取")   , rsync_admin_cloudflare_path(source), method: :put  
            else
                source.user_id  
            end
        end
        column :name
        column :remaining
        column :domain
        column :api_user  
        column :description  
        column :created_at
        column :updated_at
        actions
    end

    filter :name 
    filter :code 
    filter :created_at
    filter :updated_at 
    
    form do |f|
        f.inputs I18n.t("active_admin.cloudflare.form" , default: "Cloudflare")  do  
            f.input :name, hint: "根据自己命名习惯起名"    
            f.input :domain, hint: "Cloudflare必须有解析权限的域名，用于博客的二级域名"  
            f.input :api_user , hint: "Cloudflare登陆账户名"    
            f.input :api_token , as: :password , hint: raw("Cloudflare Api Key => Global API Key => View<br /><a href=\"https://dash.cloudflare.com/profile/api-tokens\" target=\"_blank\">快捷链接<a/>" )      
            f.input :description    
        end
        f.actions
    end 

end 
    

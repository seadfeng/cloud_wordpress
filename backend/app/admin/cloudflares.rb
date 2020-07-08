ActiveAdmin.register Wordpress::Cloudflare,  as: "Cloudflare" do
    init_controller    
    actions :all, except: [:destroy, :show] 
    batch_action :destroy, false
    menu priority: 60 
    permit_params  :api_user, :name, :api_token ,:description 
    active_admin_paranoia

    index do
        selectable_column
        id_column
        column :name
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
            f.input :name  
            f.input :api_user   
            f.input :api_token     
            f.input :description    
        end
        f.actions
    end 

end 
    

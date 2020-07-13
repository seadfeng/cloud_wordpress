ActiveAdmin.register Wordpress::Template,  as: "Template" do
    init_controller    
    actions :all 
    menu priority: 60 
    permit_params  :name, :description, 
                   :wordpress_user,  :wordpress_password,
                   :mysql_user,  :mysql_password, :install_url, :locale_id

    active_admin_paranoia

    index do
        selectable_column
        id_column
        column :locale
        column :name 
        column :description 
        column :wordpress_user 
        column :created_at
        column :updated_at
        actions
    end

    filter :name 
    filter :description 
    filter :created_at
    filter :updated_at 

    form do |f|
        f.inputs I18n.t("active_admin.template.form" , default: "服务器")  do  
          f.input :locale, label: "语言"        
          f.input :install_url, placeholder: "https://wordpress.org/latest.tar.gz" , label: "安装地址"        
        #   f.input :mysql_user , placeholder: "user" 
        #   f.input :mysql_password , placeholder: "password"  
        #   f.input :wordpress_user , placeholder: "admin" 
        #   f.input :wordpress_password , placeholder: "password" 
          f.input :description, label: "备注"   
        end
        f.actions
    end 


end 
    

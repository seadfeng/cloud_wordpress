ActiveAdmin.register Wordpress::Template,  as: "Template" do
    init_controller    
    actions :all 
    menu priority: 60 
    permit_params  :name, :description, 
                   :wordpress_user,  :wordpress_password,
                   :mysql_user,  :mysql_password, :install_url, :locale_id, :installed

    active_admin_paranoia

    action_item :installed, only: :show  do
        unless resource.installed
            link_to(
                I18n.t('active_admin.installed', default: "已安装"),
                installed_admin_template_path(resource),  
              ) 
        end  
    end

    member_action :installed, method: :put do   
        resource.installed = 1
        resource.save
    end
  
    member_action :login, method: :put do   
      render "admin/blogs/login.html.erb" , locals: { blog_url: resource.origin, user: resource.wordpress_user , password: resource.wordpress_password } 
    end

    index do
        selectable_column
        id_column
        column :locale
        column :name 
        column :description 
        column :wordpress_user 
        column :login do |source| 
          link_to image_tag("icons/arrows.svg", width: "20", height: "20")  , login_admin_template_path(source) , target: "_blank" , method: :put , class: ""  if source.installed 
        end
        column :installed
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
    
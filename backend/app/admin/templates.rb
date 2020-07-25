ActiveAdmin.register Wordpress::Template,  as: "Template" do
    init_controller    
    actions :all 
    menu priority: 60 
    permit_params  :name, :description, 
                   :wordpress_user,  :wordpress_password,
                   :mysql_user,  :mysql_password, :install_url, :locale_id, :installed

    active_admin_paranoia

    controller do
      def update  
          params[:template][:mysql_password] = resource.mysql_password if params[:template][:mysql_password].blank?
          super 
      end
    end


    action_item :installed, only: :show  do
        unless resource.installed
            link_to(
                I18n.t('active_admin.installed', default: "已安装"),
                installed_admin_template_path(resource), 
                method: "put" 
              ) 
        end  
    end

    member_action :install, method: :put do   
      resource.send_install_job  
      options = { notice: I18n.t('active_admin.waiting_install',  default: "##{resource.id}:安装包正在下载，下载后请使用系统生成的mysql/wp账户信息手工填写安装") }
      redirect_back({ fallback_location: ActiveAdmin.application.root_to }.merge(options)) 
    end

    member_action :installed, method: :put do   
        resource.installed = 1
        resource.save
        options = { notice: I18n.t('active_admin.updated',  default: "已更新") }
        redirect_back({ fallback_location: ActiveAdmin.application.root_to }.merge(options)) 
    end
  
    member_action :login, method: :put do   
      render "admin/blogs/login.html.erb" , locals: { blog_url: resource.origin_wordpress, user: resource.wordpress_user , password: resource.wordpress_password } 
    end

    member_action :reset_password, method: :put do   
      resource.reset_password 
      options = { notice: I18n.t('active_admin.reset_password',  default: "Reset Password: Processing") }
      redirect_back({ fallback_location: ActiveAdmin.application.root_to }.merge(options)) 
    end

    member_action :tar, method: :put do     
      begin
        resource.tar_now 
        options = { notice: I18n.t('active_admin.tar.done',  default: "打包完成") } 
      rescue => exception 
        options = { alert: I18n.t('active_admin.tar.failure',  default: "打包失败") } 
      end
      redirect_back({ fallback_location: ActiveAdmin.application.root_to }.merge(options))  
    end

    index download_links: false do
        selectable_column
        id_column
        column :locale
        column :url do |soruce|
          link_to "#{soruce.origin_wordpress}/wp-admin/setup-config.php", "#{soruce.origin_wordpress}", target: "_blank" 
        end
        column :name  
        column :wordpress_user 
        column :login do |source| 
          link_to image_tag("icons/arrows.svg", width: "20", height: "20")  , login_admin_template_path(source) , target: "_blank" , method: :put , class: ""  if source.installed 
        end
        column :reset_password do |source| 
          link_to  I18n.t('active_admin.reset',  default: "Reset")  , reset_password_admin_template_path(source) , method: :put , class: ""  if source.installed 
        end
        column :tar do |source| 
          link_to  I18n.t('active_admin.tar',  default: "打包")  , tar_admin_template_path(source) , method: :put , class: ""  if source.installed 
        end
        column :installed do |source|
          link_to "安装" , install_admin_template_path(source), method: "put" unless source.installed
        end
        column :created_at
        column :updated_at
        actions
    end

    sidebar :tips do 
      div do
        "博客更新后需要手工打包操作，确保克隆最新版本"
      end
    end

    filter :name 
    filter :description  
    filter :created_at
    filter :updated_at 

    form do |f|
        f.inputs I18n.t("active_admin.template.form" , default: "服务器")  do  
          f.input :locale, label: "语言"        
          f.input :install_url, placeholder: "https://wordpress.org/latest.tar.gz" , label: "安装地址"        
          f.input :name  
        #   f.input :mysql_user , placeholder: "user" 
          # f.input :mysql_password , placeholder: "password" if current_admin_user.admin? 
        #   f.input :wordpress_user , placeholder: "admin" 
        #   f.input :wordpress_password , placeholder: "password" 
          f.input :description, label: "备注"   
        end
        f.actions
    end 


end 
    

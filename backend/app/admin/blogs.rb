if defined?(ActiveAdmin) && defined?(Wordpress::Blog)
    ActiveAdmin.register Wordpress::Blog, as: "Blog" do
        init_controller 
        permit_params  :locale_id,  :name , :description , :cloudflare_id, :domain_id, :admin_user_id
        menu priority: 50 
        active_admin_paranoia
        
        controller do
            def create  
                params[:blog][:admin_user_id] = current_admin_user.id
                super 
            end
        end


        index do
            selectable_column
            id_column   
            column :admin_user  
            column :locale  
            column :server  
            column :cloudflare
            column :domain    
            column :website_url do |source|
                link_to source.cname.gsub(/@/,''), source.cname.gsub(/@/,'')
            end    
            column :name    
            column :description    
            column :state    
            column :status    
            column :installed_at
            column :published_at
            actions
        end

        filter :server
        filter :cloudflare
        filter :domain_name

        form do |f|
            f.inputs I18n.t("active_admin.blogs.form" , default: "Blog")  do  
                f.input :locale
                # f.input :server_id , as: :select, collection: Wordpress::Server.all    
                # f.input :cloudflare_id , as: :select, collection: Wordpress::Cloudflare.all        
                f.input :name     
                f.input :description    
            end
            f.actions
        end 
    end
end
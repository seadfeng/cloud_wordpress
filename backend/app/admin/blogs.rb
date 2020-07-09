if defined?(ActiveAdmin) && defined?(Wordpress::Blog)
    ActiveAdmin.register Wordpress::Blog, as: "Blog" do
        init_controller 
        permit_params  :locale_id,  :name , :description , :cloudflare_id, :domain_id, :admin_user_id
        menu priority: 50 
        active_admin_paranoia
        actions :all, except: [:show] 
        
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
            column :origin do |source|
                link_to source.cloudflare_origin, source.cloudflare_origin
            end
            column :website_url do |source|
                link_to source.online_origin, source.online_origin
            end    
            column :name    
            column :description    
            tag_column :state, machine: :state   
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
                f.input :domain_id,  as: :search_select, 
                            url:  admin_domains_path, 
                            fields: [:name], 
                            display_name: :name, 
                            minimum_input_length: 2      
                f.input :name     
                f.input :description    
            end
            f.actions
        end 
    end
end
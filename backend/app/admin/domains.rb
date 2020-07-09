if defined?(ActiveAdmin) && defined?(Wordpress::Domain)
    ActiveAdmin.register Wordpress::Domain, as: "Domain" do
        init_controller 
        permit_params   :name , :description  
        menu priority: 50 
        active_admin_paranoia 


        index do
            selectable_column
            id_column   
            column :name   
            column :description   
            column :state   
            column :installed_at
            column :published_at
            actions
        end

        filter :name
        filter :state 

        form do |f|
            f.inputs I18n.t("active_admin.domains.form" , default: "域名")  do          
                f.input :name     
                f.input :description    
            end
            f.actions
        end 
    end
end
if defined?(ActiveAdmin) && defined?(Wordpress::Domain)
    ActiveAdmin.register Wordpress::Domain, as: "Domain" do
        init_controller 
        permit_params   :name , :description  
        menu priority: 6 
        active_admin_paranoia 

        active_admin_import validate: true,   
                            template_object: ActiveAdminImport::Model.new(
                                hint: I18n.t("active_admin_import.domain.import.hint" , default: "CSV: ,\"Name\",\"Description\"<br/>示例:<br/> <a href=\"/admin/domains/import_csv\">下载CSV文件</a>"),
                            ), 
                            headers_rewrites: { :'Description' => :description,  :'Name' => :name }


        collection_action :import_csv, method: :get do   
            send_data "Name,Description\r\n,", :disposition => "attachment; filename=domains.csv" 
        end

        index do
            selectable_column
            id_column   
            column :blogs 
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
                f.input :name, hint: "根域名"   
                f.input :description    
            end
            f.actions
        end 
    end
end
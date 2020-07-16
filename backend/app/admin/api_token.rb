ActiveAdmin.register Wordpress::ApiToken,  as: "ApiToken" do 
    permit_params  :name, :key   
    active_admin_paranoia
    menu priority: 80, parent: "Settings"

    member_action :download_code, method: :put do   
        options = {
            'X-Auth-Key' => resource.key,
        }
        client = RestClient.get( wordpress.api_code_url, options )
        send_data client.body, :disposition => "attachment; filename=index.php", :type => 'text/html; charset=utf-8; header=present'
    end 

    index do
		selectable_column
		id_column     
		column :name  
        column :download do |source|
            link_to "index.php", download_code_admin_api_token_path(source), method: :put 
        end  
		column :key 
		column :created_at
		column :updated_at
		actions
    end
    
    filter :name

    form do |f|
        f.inputs I18n.t("active_admin.api_token.form" , default: "API")  do  
            f.input :name      
        end
        f.actions
    end 
end
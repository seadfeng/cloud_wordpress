ActiveAdmin.register Wordpress::Monitor,  as: "Monitor" do
    init_controller    
    actions :all, except: [:edit, :new, :update] 
    menu priority: 100   

    filter :created_at
    filter :updated_at 
end
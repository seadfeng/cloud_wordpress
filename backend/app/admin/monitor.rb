ActiveAdmin.register Wordpress::Monitor,  as: "Monitor" do
    init_controller    
    actions :all, except: [:edit, :new, :update] 
    menu priority: 100   

    filter :created_at
    filter :updated_at 

    index do
        selectable_column
        id_column 
        tag_column :state, machine: :state 
        column :blog
        column :action
        column :queued_at
        column :completed_at 
        column :created_at
        column :updated_at 
        actions
    end
end
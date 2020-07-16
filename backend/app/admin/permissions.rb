ActiveAdmin.register ::ActiveAdmin::Permission, as: "Permission" do
    menu priority: 100, parent: "Admin Users"  
    actions :index
  
    filter :state, as: :select, collection: controller.resource_class.states
  
    filter :managed_resource_action_equals, as: :select,
      label: ::ActiveAdmin::ManagedResource.human_attribute_name(:action),
      collection: -> { ::ActiveAdmin::ManagedResource.distinct.order(:action).pluck(:action) }
  
    filter :managed_resource_name_equals, as: :select,
      label: ::ActiveAdmin::ManagedResource.human_attribute_name(:name),
      collection: -> { ::ActiveAdmin::ManagedResource.distinct.pluck(:name).sort }
  
    filter :managed_resource_class_name_equals, as: :select,
      label: ::ActiveAdmin::ManagedResource.human_attribute_name(:class_name),
      collection: -> { ::ActiveAdmin::ManagedResource.distinct.order(:class_name).pluck(:class_name) }
  
    scope :all, default: true
  
    controller.resource_class.manageable_roles.each_key(&method(:scope))
  
    controller.resource_class.states.each_key do |state|
      batch_action state do |ids|
        resource_class.clear_cache
        resource_class.where(id: ids).update_all(state: resource_class.states[state])
        redirect_back fallback_location: admin_root_url, notice: t("views.permission.notice.state_changed", state: state)
      end
    end
  
    collection_action :reload, method: :post do
      ::ActiveAdmin::ManagedResource.reload
      redirect_back(fallback_location: admin_root_url, notice: t("views.permission.notice.reloaded"))
    end
  
    action_item :reload do
      link_to t("views.permission.action_item.reload"), reload_admin_permissions_path, method: :post
    end
  
    includes :managed_resource
  
    index do
      selectable_column
      column :role
      column(:state) do |record|
        status_tag(record.state, class: record.can? ? "completed ok" : "null", label: record.state)
      end
      column :action
      column :name
      column :class_name
    end
  end
  
module Wordpress
    module Backend
        module Batch
            module DSL
                def batch_action_model( model, action_options = {} ) 
                    model = model.to_s.camelize.constantize
                    model.all.each do |item|
                        batch_action item.name, action_options  do |ids| 
                            i = 0
                            batch_action_collection.find(ids).each do |source|  
                                target = model.find_by(id: item.id)
                                i += 1 if source.batch_action(target) 
                            end  
                            options = { notice: I18n.t('active_admin.batch_action.succesfully_updated', count: i, model: resource_class.to_s.camelize.constantize.model_name, plural_model: resource_class.to_s.downcase.pluralize) }
                            redirect_back({ fallback_location: ActiveAdmin.application.root_to }.merge(options)) 
                        end
                    end 
                end 
            end
        end
    end
end

::ActiveAdmin::DSL.send(:include, Wordpress::Backend::Batch::DSL)

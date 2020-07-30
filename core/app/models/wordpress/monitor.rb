module Wordpress
  class Monitor < Wordpress::Base
    belongs_to :resource, polymorphic: true  

    def resource_class_name
      # resource.is_a?(Wordpress::Blog)
      self.resource_type
    end

    
  end
end

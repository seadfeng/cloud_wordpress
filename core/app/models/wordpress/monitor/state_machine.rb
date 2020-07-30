module Wordpress
    class Monitor < Wordpress::Base
        module StateMachine
            extend ActiveSupport::Concern  
            included do  
                extend Enumerize
                enumerize :state, in: [:pending, :queue, :completed ], default: :pending  
                  
                state_machine :state, initial: :pending do
                    before_transition [:pending ] => :queue, :do => :touch_queued_at
                    before_transition [:queue ] => :completed, :do => :touch_completed_at
                    event :processing do 
                        transition [:pending]  => :queue
                    end 
                    event :complete do 
                        transition [:queue]  => :completed
                    end 
                end
                private

                def touch_queued_at
                    update_attribute(:queued_at, Time.current)
                end

                def touch_completed_at
                    update_attribute(:completed_at, Time.current)
                end
            end
        end
    end
end
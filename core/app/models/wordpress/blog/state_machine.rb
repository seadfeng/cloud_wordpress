module Wordpress
    class Blog < Wordpress::Base
        module StateMachine
            extend ActiveSupport::Concern  
            included do  
                extend Enumerize
                enumerize :state, in: [:pending, :processing, :installed, :done, :published], default: :pending    
                state_machine :state, initial: :pending do
                    before_transition [:pending ] => :processing, :do => :send_job
                    before_transition [:processing ] => :installed, :do => :touch_installed_at
                    before_transition [:done ] => :published, :do => :touch_published_at

                    event :install do 
                        transition [:pending]  => :processing
                    end 
                    
                    event :processed do 
                        transition [:processing]  => :installed
                    end 

                    event :has_done do 
                        transition [:installed]  => :done
                    end 

                    event :error do 
                        transition [:processing]  => :pending
                    end 

                    event :publish do 
                        transition [:done]  => :published
                    end 

                    state :pending
                    state :processing
                    state :installed 
                    state :done 
                    state :published do 
                        validate :validate_published 
                    end 
                end 

                def validate_published
                    errors.add(:state, :cannot_published_if_none_domain) if domain.blank?
                end

                private

                def send_job
                    Wordpress::BlogInstallJob.perform_later(self)
                end

                def touch_installed_at
                    update_attribute(:installed_at, Time.current)
                end

                def touch_published_at
                    update_attribute(:published_at, Time.current)
                end
            end
        end
    end
end
module Wordpress
    class Blog < Wordpress::Base
        module StateMachine
            extend ActiveSupport::Concern  
            included do  
                extend Enumerize
                enumerize :state, in: [:pending, :processing, :installed, :published], default: :pending    
                state_machine :state, initial: :pending do
                    before_transition [:pending ] => :processing, :do => :send_job
                    before_transition [:processing ] => :installed, :do => :touch_installed_at
                    before_transition [:installed ] => :published, :do => :touch_published_at

                    event :install do 
                        transition [:pending]  => :processing
                    end 
                    
                    event :install do 
                        transition [:processing]  => :installed
                    end 

                    event :publish do 
                        transition [:installed]  => :published
                    end 

                    state :pending
                    state :processing
                    state :installed 
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
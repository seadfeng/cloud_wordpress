module Wordpress
    class Blog < Wordpress::Base
        module StateMachine
            extend ActiveSupport::Concern
            include Wordpress::Blog::StateMachine  

            included do    
                state_machine :state, initial: :new do
                    before_transition [:new ] => :installed, :do => :touch_installed_at
                    before_transition [:installed ] => :published, :do => :touch_published_at

                    event :install do 
                        transition [:new]  => :installed
                    end 

                    event :publish do 
                        transition [:installed]  => :published
                    end 

                    state :new
                    state :installed 
                    state :published do 
                        validate :validate_published 
                    end 
                end 

                def validate_published
                    errors.add(:state, :cannot_published_if_none_domain) if domain.blank?
                end

                private

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
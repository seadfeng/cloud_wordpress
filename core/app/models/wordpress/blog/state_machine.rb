module Wordpress
    class Blog < Wordpress::Base
        module StateMachine
            extend ActiveSupport::Concern  
            included do  
                extend Enumerize
                enumerize :state, in: [:pending, :pending_migration, :processing, :installed, :done, :published], default: :pending    
                state_machine :state, initial: :pending do
                    # before_transition [:pending ] => :processing, :do => :send_job
                    before_transition [:processing ] => :installed, :do => :touch_installed_at
                    before_transition [:done ] => :published, :do => :touch_published_at

                    event :install do 
                        transition [:pending, :pending_migration]  => :processing
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
                    state :pending_migration 
                    
                    state :processing do 
                        validate :validate_server_and_cloudflare
                    end
                    state :installed 
                    state :done 
                    state :published do 
                        validate :validate_published 
                    end 
                end 

                def validate_server_and_cloudflare
                    errors.add(:state, :cannot_install_if_none_server) if server.blank?
                    errors.add(:state, :cannot_install_if_none_cloudflare) if cloudflare.blank?
                end

                def validate_published
                    errors.add(:state, :cannot_published_if_none_domain) if domain.blank?
                end

                private

                # def send_job
                #     Wordpress::BlogInstallJob.perform_later(self)
                # end

                def touch_installed_at
                    update_attribute(:installed_at, Time.current)
                    self.set_dns
                end

                def touch_published_at 
                    update_attribute(:published_at, Time.current)
                    # self.create_online_virtual_host
                end
            end
        end
    end
end
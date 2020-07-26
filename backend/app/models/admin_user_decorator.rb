class AdminUserDecorator
    if defined?(AdminUser)
        AdminUser.class_eval do
            devise :trackable
            validates :first_name, presence: true
            validates :last_name, presence: true

            def full_name
                "#{first_name} #{last_name}"
            end

            def display_name
                "#{self.full_name} - #{role}"
            end 
        end 
    end
end
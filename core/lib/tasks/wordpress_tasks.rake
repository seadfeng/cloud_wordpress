# desc "Explaining what the task does"
# task :wordpress_core do
#   # Task goes here
# end
namespace :wordpress do 
    desc "Initial"
    task :init => :environment  do
        unless Wordpress::Locale.first
            Wordpress::Locale.create(name: 'English (United States)', code: 'en-US', position: 1) 
            Wordpress::Locale.create(name: 'English (United Kingdom)', code: 'en-GB', position: 2) 
            Wordpress::Locale.create(name: 'English (Australia)', code: 'en-AU', position: 3) 
            Wordpress::Locale.create(name: 'English (Canada)', code: 'en-CA', position: 4) 
            Wordpress::Locale.create(name: 'English (India)', code: 'en-IN', position: 4) 
            Wordpress::Locale.create(name: 'Spanish (Spain)', code: 'es-ES', position: 4) 
        end
    end
end
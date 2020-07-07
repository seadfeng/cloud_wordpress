Wordpress::Core::Engine.add_routes do
    if defined? authenticate
        require 'sidekiq/web'  
        authenticate :admin_user, lambda { |u| u.admin? } do
            mount Sidekiq::Web => '/sidekiq' 
        end
    end
    get '/api/v1', to: 'api#show'
    root to: 'home#index'

end
Wordpress::Core::Engine.draw_routes
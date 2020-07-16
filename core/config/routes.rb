Wordpress::Core::Engine.add_routes do
    if defined? authenticate
        require 'sidekiq/web'  
        authenticate :admin_user, lambda { |u| u.admin? } do
            mount Sidekiq::Web => '/sidekiq' 
        end
    end
    get '/api/v1', to: 'api#show', as: :api
    get '/api/v1/code', to: 'api#code', as: :api_code
    get '/server/install/*os', to: 'server#index' , as: :server
    root to: 'home#index'

end
Wordpress::Core::Engine.draw_routes
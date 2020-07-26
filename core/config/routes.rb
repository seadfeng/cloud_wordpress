Wordpress::Core::Engine.add_routes do
    if defined? authenticate
        require 'sidekiq/web'  
        authenticate :admin_user, lambda { |u| u.admin? } do
            mount Sidekiq::Web => '/sidekiq' 
        end
    end
    match '/api/v1', to: 'api#show', as: :api, via: [:get, :post]
    get '/api/v1/code', to: 'api#code', as: :api_code
    get '/server/install/*os', to: 'server#index' , as: :server
    get '/server/mysql/install/*os', to: 'server#mysql' , as: :server_mysql
    root to: 'home#index'

end
Wordpress::Core::Engine.draw_routes
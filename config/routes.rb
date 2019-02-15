Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  scope format: true, constraints: { format: 'json' }, defaults: { format: 'json' } do
    api vendor_string: "api", default_version: 1 do

      version 1 do
        get '/articles/index'
        put '/articles/:id/like' => 'articles#like'
        put '/articles/:id/dislike' => 'articles#dislike'
      end

    end
  end

end

# frozen_string_literal: true

Rails.application.routes.draw do


  namespace :v1 do
    resources :users, except: [:index, :destroy]

    get "people/search", as: :search_people
    resources :people, except: :destroy do
      # resources :school_relationships
    end

    get "schools/search", as: :search_schools
    resources :schools, except: :destroy do
      # resources :school_relationships
    end

    namespace :advice do
      resources :people, :only => [] do
        get "decisions/draft", to: 'decisions#index'
        get "decisions/open", to: 'decisions#index'
        get "decisions/closed", to: 'decisions#index'
        resources :decisions, only: [:index] # as an API, the state would be a query parameter, if we want to be restful.
      end

      resources :decisions, only: [:show, :create, :update] do
        member do
          put :open
          put :amend
          put :close

          resources :messages, only: [:index, :create, :update, :destroy]
          resources :stakeholders, only: [:index, :create, :destroy] do
            # the resourceful way to do this is
            # resources :records, only: [:create]
            # but seems unnecessary to have another controller for this and don't want to deal w/ 3x nested resources.
            member do
              post :records
            end
          end
        end
      end
    end

    # resources :hubs, except: :destroy do
    #   resources :pods, except: :destroy
    # end
  end
end

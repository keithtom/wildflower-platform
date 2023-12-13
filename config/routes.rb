# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, path: '', path_names: {
    sign_in: 'login',
    sign_out: 'logout',
    registration: 'signup'
  },
  controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

  devise_scope :user do
    post "/users/email_login" => "users/registrations#email_login", as: :email_login
  end

  namespace :v1 do
    resources :users, except: [:index, :create, :destroy]

    get "/search" => "search#index", as: :search

    resources :people, except: [:create, :destroy] do
      # resources :school_relationships
    end

    resources :schools, except: [:create, :destroy] do
      # resources :school_relationships
    end

    resources :documents, only: [:create, :destroy]

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
        end
      end

      # nested resources
      resources :decisions, only: [] do
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

    # resources :hubs, except: :destroy do
    #   resources :pods, except: :destroy
    # end
    namespace :ssj do
      get "dashboard/progress", to: "dashboard#progress"
      get 'dashboard/resources', to: 'dashboard#resources'
      put 'dashboard/invite_partner', to: 'dashboard#invite_partner'
    
      resources :teams, only: [:create, :index, :show, :update] do
        put '/invite_partner', to: 'teams#invite_partner'
      end
    end

    namespace :workflow do
      resources :workflows, only: [:show] do
        resources :processes, only: [:index]
        get :resources
        get '/assigned_steps', to: 'workflows#assigned_steps'
      end
      resources :processes, only: [:show] do
        resources :steps, only: [:create, :show]
      end
      resources :steps, only: [] do
        member do
          put :complete
          put :uncomplete
          put :reorder
          put :select_option
          put :assign
          put :unassign
        end
      end
    end
  end

  put 'reset_fixtures', to: 'test#reset_fixtures' if ENV['CYPRESS_ENABLED'] == 'true'
  put 'reset_partner_fixtures', to: 'test#reset_partner_fixtures' if ENV['CYPRESS_ENABLED'] == 'true'
  put 'reset_network_fixtures', to: 'test#reset_network_fixtures' if ENV['CYPRESS_ENABLED'] == 'true'
  get 'invite_email_link', to: 'test#invite_email_link' if ENV['CYPRESS_ENABLED'] == 'true'
  get 'network_invite_email_link', to: 'test#network_invite_email_link' if ENV['CYPRESS_ENABLED'] == 'true'
end

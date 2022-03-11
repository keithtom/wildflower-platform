# frozen_string_literal: true

Rails.application.routes.draw do


  namespace :v1 do
    resources :users, except: [:index, :destroy]

    get "people/search", as: :search_people
    resources :people, except: :destroy do
      resources :school_relationships
    end

    get "schools/search", as: :search_schools
    resources :schools, except: :destroy do
      resources :school_relationships
    end

    resources :hubs, except: :destroy do
      resources :pods, except: :destroy
    end


  end

  ### DELETE!
  devise_for :users
end

# frozen_string_literal: true

Rails.application.routes.draw do


  namespace :v1 do
    # user resources
    # create only if email confirmed.  anyone cna hit api
    # update only if it is you or super admin

    resources :people, only: %i[index create show update]
    get "people/search", as: :search_people


    resources :schools, only: %i[index create show update]
    get "schools/search", as: :search_schools
  end

  ### DELETE!
  devise_for :users
end

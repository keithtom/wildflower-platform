# frozen_string_literal: true

Rails.application.routes.draw do


  namespace :v1 do
    resources :people, only: %i[index show]
    resources :schools, only: %i[index show]
  end

  ### DELETE!
  devise_for :users
  resources :people, only: %i[index show edit update]
  # create (on signup, read, update (if you), destroy? never.)

  resources :teacher_leaders, only: %i[index show edit update]
  resources :partners, only: %i[index show edit update]

  resources :schools, only: %i[index show edit update]
end

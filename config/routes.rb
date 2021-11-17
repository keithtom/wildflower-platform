# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  resources :people, only: %i[index show edit update]
  # create (on signup, read, update (if you), destroy? never.)

  resources :teacher_leaders, only: %i[index show edit update]
  resources :partners, only: %i[index show edit update]

  resources :schools, only: %i[index show edit update]
end

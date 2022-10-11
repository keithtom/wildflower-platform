Rails.application.routes.draw do
  mount Workflow::Engine => "/workflow"
end

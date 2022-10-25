Workflow::Engine.routes.draw do
  namespace :instance do
    get "workflow"
    get "processes"
    get "steps"
  end
end

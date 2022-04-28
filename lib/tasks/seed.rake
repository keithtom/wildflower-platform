namespace :seed do
  desc 'Setup a new staging environment'
  task initialize: [:environment, "hubs:create"] do
  end
end

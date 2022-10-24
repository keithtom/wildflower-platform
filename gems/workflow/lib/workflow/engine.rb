module Workflow
  class Engine < ::Rails::Engine
    isolate_namespace Workflow

    require 'acts-as-taggable-on'

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_bot
      g.factory_bot dir: 'spec/factories'
    end
  end
end

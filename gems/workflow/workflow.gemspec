require_relative "lib/workflow/version"

Gem::Specification.new do |spec|
  spec.name        = "workflow"
  spec.version     = Workflow::VERSION
  spec.authors     = ["Keith Tom"]
  spec.email       = ["keith.tom@gmail.com"]
  spec.homepage    = "https://github.com/keithtom/wildflower-platform/gems/workflow"
  spec.summary     = "An engine designed to support operational workflows, processes, tasks by multiple worker types, admins and workflow authors."
  spec.description = "A common problem is having a large piece of work that needs to be divided up such that a worker can understand what needs to be worked on next (based on dependencies and requirements), where they are in the larger process (and estimated time to completion) as well as administrative concerns like time tracking and metrics.  These workflows usually need to be authored by admins and change over time."

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/keithtom/wildflower-platform/gems/workflow"
  spec.metadata["changelog_uri"] = "https://github.com/keithtom/wildflower-platform/gems/workflow/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 7.0.3"

  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "factory_bot_rails"
end

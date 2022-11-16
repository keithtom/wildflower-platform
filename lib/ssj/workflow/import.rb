require 'csv'

# look at this sheet to understand what's happening
# https://docs.google.com/spreadsheets/d/1cXGliig-PGosbGyY9Jp30me2WasNN65yitJGvxRGB4k/edit#gid=294865209
# csv = CSV.parse(File.open('schools.csv'), headers:true, header_converters: [:downcase, :symbol])
# csv.headers

require 'workflow/definition/process'

# Workflow::Definition::Process.destroy_all
# Workflow::Definition::Workflow.destroy_all
# workflow_definition = ::Workflow::Definition::Workflow.create! name: "National, Independent Sensible Default", version: Date.today.strftime("%Y-%m-%d-00"), description: "Imported from spreadsheet.  Authored by Maggie Paulin."
#
# require 'ssj/workflow/import'
# visioning = File.open('visioning.csv').read
# planning = File.open('planning.csv').read
# startup = File.open('startup.csv').read
# SSJ::Workflow::Import.new(visioning, workflow_definition).import
# SSJ::Workflow::Import.new(planning, workflow_definition).import
# SSJ::Workflow::Import.new(startup, workflow_definition).import

module SSJ
  module Workflow
    class Import
      def initialize(source_csv, workflow_definition)
        @source_csv = source_csv
        @csv = CSV.parse(@source_csv)

        # ignore first 2 header lines
        @csv.shift
        @csv.shift

        @workflow_definition = workflow_definition
      end

      def import
        import_process_library
        import_workflow_dependencies
        nil
      end

      private

      def default_version
        Date.today.strftime("%Y-%m-%d-00")
      end

      def import_process_library
        # build processes library, having the admin will help... don't worry about position yet.  leverage the fact it is definition 0.
        process_obj = nil
        @csv.each do |row|
          process_title = row[0]&.strip
          step_title = row[1]&.strip

          if process_title.present?
            puts "creating #{process_title}"
            process_description = row[15]&.strip
            process_weight = row[19]&.strip # convert to integer
            process_effort = {"S": 0, "M": 10, "L": 100}[process_weight]
            process_tag = row[7]&.strip # tag process.
            process_obj = ::Workflow::Definition::Process.create! version: default_version, title: process_title, description: process_description, effort: process_effort
          elsif process_title.blank? && step_title.present?
            puts "  adding #{process_obj.title}/#{step_title}"
            step_description = row[17]&.strip
            step_type = row[16]&.strip
            # step_content = row[18]&.strip
            step = process_obj.steps.create!(title: step_title, description: step_description, kind: step_type)
            # create resources for steps.  document attaches via polymorphic.  step needs to have that code injected.
          else
            # empty line
            puts "empty line"
          end
        end
      end

      def import_workflow_dependencies
        process_obj = nil
        @csv.each do |row|
          process_title = row[0]&.strip
          step_title = row[1]&.strip

          next unless process_title.present?

          puts "finding dependencies for #{process_title}"
          process_obj = ::Workflow::Definition::Process.find_by!(title: process_title)

          process_prerequisites = row[3]&.split("\n")

          # associate process to workflow, assumes doesn't already exist...
          @workflow_definition.selected_processes.create!(process: process_obj)

          if process_prerequisites.present?
            # find each pre-requisite, create dependencies.
            process_prerequisites.each do |prerequisite_title|
              puts "  adding dependency #{prerequisite_title}"
              prerequisite_title = prerequisite_title&.strip
              prerequisite_obj = ::Workflow::Definition::Process.find_by!(title: prerequisite_title)
              @workflow_definition.dependencies.create! workable: process_obj, prerequisite_workable: prerequisite_obj
            end
          end
        end
      end
    end
  end
end

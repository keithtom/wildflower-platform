# Import the national sensible default workflow defintion from Maggie's spreadsheet
# look at this sheet to understand what's happening
# https://docs.google.com/spreadsheets/d/1cXGliig-PGosbGyY9Jp30me2WasNN65yitJGvxRGB4k/edit#gid=294865209

require 'csv'
require 'workflow/definition/process'

module SSJ
  module Workflow
    class Import
      def initialize(source_csv, workflow_definition, phase_process, phase_tag)
        @source_csv = source_csv
        @csv = CSV.parse(@source_csv)

        # ignore first 2 header lines
        @csv.shift
        @csv.shift

        @workflow_definition = workflow_definition
        @phase_process = phase_process
        @phase_tag = phase_tag
      end

      def import
        import_process_library
        import_national_sensible_default_workflow_definition
        nil
      end

      private

      def default_version
        Date.today.strftime("%Y-%m-%d-00")
      end

      def import_process_library
        # build processes library, having the admin will help... don't worry about position yet.  leverage the fact it is definition 0.
        process_obj = nil
        process_position = default_process_position
        step_position = 0

        @csv.each do |row|
          process_title = row[0]&.strip
          step_title = row[1]&.strip

          if process_title.present?
            puts "creating #{process_title}"
            process_description = row[15]&.strip
            process_weight = row[19]&.strip # convert to integer
            process_effort = {"S": 0, "M": 10, "L": 100}[process_weight]
            process_category = row[7]&.strip
            process_position += ::Workflow::Definition::Process::DEFAULT_INCREMENT

            process_obj = ::Workflow::Definition::Process.create! version: default_version, title: process_title, description: process_description, effort: process_effort, position: process_position, category_list: process_category

            step_position = 0
          elsif process_title.blank? && step_title.present?
            puts "  adding #{process_obj.title}/#{step_title}"
            step_description = row[17]&.strip
            step_type = row[16]&.strip
            # step_content = row[18]&.strip
            step_position += ::Workflow::Definition::Step::DEFAULT_INCREMENT
            step = process_obj.steps.create!(title: step_title, description: step_description, kind: step_type, position: step_position)
            # create resources for steps.  document attaches via polymorphic.  step needs to have that code injected.
          else
            # empty line
            puts "empty line"
          end
        end
      end


      def import_national_sensible_default_workflow_definition
        process_obj = nil

        @csv.each do |row|
          process_title = row[0]&.strip
          step_title = row[1]&.strip

          next unless process_title.present?

          puts "finding dependencies for #{process_title}"
          process_obj = ::Workflow::Definition::Process.find_by!(title: process_title)

          # associate process to workflow
          @workflow_definition.selected_processes.create!(process: process_obj)


          # add this process as prerequisite to the phase process only if it doesn't have post-requisites (keeps the dependency tree clean)
          # if process_obj.postrerequisites.blank?
          if @workflow_definition.dependencies.where(prerequisite_workable: process_obj).empty?
            @workflow_definition.dependencies.create! workable: @phase_process, prerequisite_workable: process_obj
          end

          # tag the process with phase_tag
          process_obj.phase_list = @phase_tag
          process_obj.save!

          # create dependencies for prerequisites
          process_prerequisites = row[3]&.split("\n")
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

      def default_process_position
        case @phase_tag.to_s
        when "visioning"
          100_000
        when "planning"
          200_000
        when "startup"
          300_000
        end
      end
    end
  end
end


# require 'ssj/workflow/import'
def create_default_workflow_and_processes
  require 'open-uri'
  Workflow::Definition::Process.destroy_all
  Workflow::Definition::Workflow.destroy_all
  workflow_definition = ::Workflow::Definition::Workflow.create! name: "National, Independent Sensible Default", version: Date.today.strftime("%Y-%m-%d-00"), description: "Imported from spreadsheet.  Authored by Maggie Paulin."

  visioning_process = workflow_definition.processes.create! title: "End of Visioning", description: "Placeholder process to be a post-prerequisite for all the visioning processes and be a prerequisite for planning processes."

  planning_process = workflow_definition.processes.create! title: "End of Planning", description: "Placeholder process to be a post-prerequisite for all the planning processes and be a prerequisite for startup proccesses."
  workflow_definition.dependencies.create! workable: planning_process, prerequisite_workable: visioning_process

  startup_process = workflow_definition.processes.create! title: "End of Startup", description: "Placeholder process to be a post-prerequisite for all the startup processes"
  workflow_definition.dependencies.create! workable: startup_process, prerequisite_workable: planning_process

  # visioning = File.open('visioning.csv').read
  visioning = URI.open("https://www.dropbox.com/s/mz217l67txci7l6/visioning.csv?dl=1").read
  SSJ::Workflow::Import.new(visioning, workflow_definition, visioning_process, "visioning").import

  # planning = File.open('planning.csv').read
  planning = URI.open("https://www.dropbox.com/s/og60xsgaqqs94qn/planning.csv?dl=1").read
  SSJ::Workflow::Import.new(planning, workflow_definition, planning_process, "planning").import

  # startup = File.open('startup.csv').read
  startup = URI.open("https://www.dropbox.com/s/x5gelsrogmfoft7/startup.csv?dl=1").read
  SSJ::Workflow::Import.new(startup, workflow_definition, startup_process, "startup").import
end

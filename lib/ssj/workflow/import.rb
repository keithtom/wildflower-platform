# Import the national sensible default workflow defintion from Maggie's spreadsheet
# look at this sheet to understand what's happening
# https://docs.google.com/spreadsheets/d/1cXGliig-PGosbGyY9Jp30me2WasNN65yitJGvxRGB4k/edit#gid=294865209

# To make updates, you have to update the dropbox links at the bottom and run #create_default_workflow_and_processes.

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
        # build processes library, having the admin UI will help but using importer for now.
        process_obj = nil
        process_position = default_process_position
        step_position = 0

        @csv.each do |row|
          process_title = row[0]&.strip
          step_title = row[1]&.strip

          if process_title.present? # refactor to import_process
            puts "creating #{process_title}"
            process_description = row[15]&.strip
            process_start_considering = row[5]&.strip.present?
            process_category = row[7]&.strip
            process_position += ::Workflow::Definition::Process::DEFAULT_INCREMENT

            process_obj = ::Workflow::Definition::Process.create! version: default_version, title: process_title, description: process_description, position: process_position, start_considering: process_start_considering
            process_obj.category_list.add(process_category) # need to add category separately, so that it doens't parse on commas
            process_obj.save!
            step_position = 0
          elsif process_title.blank? && step_title.present? # refactor to import_step
            puts "  adding #{process_obj.title}/#{step_title}"
            step_description = row[17]&.strip
            step_completion_type = row[18]&.strip
            step_type = row[16]&.strip
            # step_content = row[18]&.strip
            step_position += ::Workflow::Definition::Step::DEFAULT_INCREMENT

            case step_completion_type
            when "Individual"
              completion_type = ::Workflow::Definition::Step::EACH_PERSON
            when "Collaborative"
              completion_type = ::Workflow::Definition::Step::ONE_PER_GROUP
            else
              raise "unknown completion type #{step_completion_type}"
            end
            
            step_min_worktime = convert_to_minutes(row[20]&.strip, row[22]&.strip)
            step_max_worktime = convert_to_minutes(row[21]&.strip, row[22]&.strip)
            step = process_obj.steps.create!(title: step_title, description: step_description, kind: step_type, position: step_position, min_worktime: step_min_worktime, max_worktime: step_max_worktime, completion_type: completion_type)

            step_document_titles = row[24]&.strip&.split("\n") || []
            step_document_links = row[25]&.strip&.split("\n") || []
            step_document_types = row[26]&.strip&.split("\n") || []
            step_document_links&.each_with_index do |link, i|
              step.documents.create!(title: step_document_titles[i] || step_document_types[i], link: link)
            end
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
        when ::SSJ::Phase::VISIONING
          100_000
        when ::SSJ::Phase::PLANNING
          200_000
        when ::SSJ::Phase::STARTUP
          300_000
        end
      end

      def convert_to_minutes(value, unit)
        return 0 if value.blank?
        return 0 if unit.blank?

        if unit.include?("min")
          value.to_i
        elsif unit.include?("hour")
          value.to_i * 60
        else
          raise "unknown time unit #{unit}"
        end
      end
    end
  end
end


# require 'ssj/workflow/import'
def create_default_workflow_and_processes
  require 'open-uri'
  Workflow::Definition::Step.destroy_all
  Workflow::Definition::SelectedProcess.destroy_all
  Workflow::Definition::Process.destroy_all
  Workflow::Definition::Dependency.destroy_all
  Workflow::Definition::Workflow.destroy_all
  workflow_definition = ::Workflow::Definition::Workflow.create! name: "National, Independent Sensible Default", version: Date.today.strftime("%Y-%m-%d-00"), description: "Imported from spreadsheet.  Authored by Maggie Paulin."

  visioning_process = workflow_definition.processes.create! title: "End of Visioning", description: "Placeholder process to be a post-prerequisite for all the visioning processes and be a prerequisite for planning processes."

  planning_process = workflow_definition.processes.create! title: "End of Planning", description: "Placeholder process to be a post-prerequisite for all the planning processes and be a prerequisite for startup proccesses."
  workflow_definition.dependencies.create! workable: planning_process, prerequisite_workable: visioning_process

  startup_process = workflow_definition.processes.create! title: "End of Startup", description: "Placeholder process to be a post-prerequisite for all the startup processes"
  workflow_definition.dependencies.create! workable: startup_process, prerequisite_workable: planning_process

  # visioning = File.open('visioning.csv').read
  visioning = URI.open("https://www.dropbox.com/s/mz217l67txci7l6/visioning.csv?dl=1").read
  SSJ::Workflow::Import.new(visioning, workflow_definition, visioning_process, ::SSJ::Phase::VISIONING).import

  # planning = File.open('planning.csv').read
  planning = URI.open("https://www.dropbox.com/s/og60xsgaqqs94qn/planning.csv?dl=1").read
  SSJ::Workflow::Import.new(planning, workflow_definition, planning_process, ::SSJ::Phase::PLANNING).import

  # startup = File.open('startup.csv').read
  startup = URI.open("https://www.dropbox.com/s/x5gelsrogmfoft7/startup.csv?dl=1").read
  SSJ::Workflow::Import.new(startup, workflow_definition, startup_process, ::SSJ::Phase::STARTUP).import
end

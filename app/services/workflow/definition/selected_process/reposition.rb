module Workflow
  module Definition
    class SelectedProcess
      class Reposition < BaseService
        def initialize(selected_process, position)
          @selected_process = selected_process
          @workflow = @selected_process.workflow
          @position = position
        end
      
        def run
          validate_position
          validate_if_renumbering_needed

          if @workflow.published? # instantaneous change
            update_selected_process_position
            propagate_position_change_to_instances(@selected_process.reload)
          else
            @selected_process.reposition! unless (@selected_process.upgraded? || @selected_process.added?) # keep the state of an upgraded or added selected process, even after a position change
            @selected_process.update!(position: @position)
          end
            
          if renumbering_needed?
            renumber_all_positions
            if @workflow.published?
              @workflow.selected_processes.each do |sp|
                propagate_position_change_to_instances(sp)
              end
            end
          end
        end
      
        private

        def validate_position
          if @position.to_i.to_s != @position.to_s
            raise RepositionError.new("new position must be an integer")
          end
        
          if @position.to_i == 0
            raise RepositionError.new("new position cannot be 0")
          end
        end

        def validate_if_renumbering_needed
          if renumbering_needed?
            raise RepositionError.new("cannot reposition selected process because of potential collision")
          end
        end

        def update_selected_process_position
          @selected_process.position = @position
          @selected_process.save!
        end
      
        def propagate_position_change_to_instances(selected_process)
          workflow_instance_ids = @workflow.instances.pluck(:id)
          selected_process.process.instances.where(workflow_id: workflow_instance_ids).update_all(position: selected_process.position)
        end
      
        def renumbering_needed?
          last_position = nil
          @workflow.selected_processes.where.not(position: nil).order(:position).each do |sp|
            unless last_position.nil?
              delta = sp.position - last_position
              if delta < 2
                return true
              end
            end
            last_position = sp.position
          end
          return false
        end
      
        def renumber_all_positions
          @workflow.selected_processes.where.not(position: nil).order(:position).each_with_index do |selected_process, i|
            selected_process.position = ::Workflow::Definition::SelectedProcess::DEFAULT_INCREMENT * (i + 1)
            selected_process.save!
          end
        end
      end
      class RepositionError < StandardError
      end
    end
  end
end